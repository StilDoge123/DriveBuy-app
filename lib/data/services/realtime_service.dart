import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../config/api_config.dart';

typedef RealtimeMessageHandler = void Function(Map<String, dynamic> message);
typedef ChatMessageHandler = void Function(Map<String, dynamic> message);

class RealtimeService {
  StompClient? _client;
  bool _isConnected = false;
  final Map<String, void Function()> _subscriptions = {};
  final Map<String, ChatMessageHandler> _chatHandlers = {};
  String? _currentUserId;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;

  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }

  String _buildWebSocketUrl() {
    const base = ApiConfig.domainUrl;
    final isSecure = base.startsWith('https://');
    final wsBase = base.replaceFirst(isSecure ? 'https://' : 'http://', isSecure ? 'wss://' : 'ws://');
    // Spring SockJS endpoint with native WebSocket transport
    return '$wsBase/ws/websocket';
  }

  Future<void> _ensureConnected() async {
    if (_isConnected && _client != null) {
      print('🔍 RealtimeService: Already connected to WebSocket');
      return;
    }

    // If already connecting, wait for the existing connection attempt
    if (_isConnecting && _connectionCompleter != null) {
      print('🔍 RealtimeService: Already connecting, waiting for existing connection...');
      await _connectionCompleter!.future;
      return;
    }

    // Start new connection attempt
    _isConnecting = true;
    _connectionCompleter = Completer<void>();

    try {
      print('🔍 RealtimeService: Connecting to WebSocket...');
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final url = _buildWebSocketUrl();
      print('🔍 RealtimeService: WebSocket URL: $url');
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      _client = StompClient(
        config: StompConfig(
          url: url,
          onConnect: (frame) {
            print('🔍 RealtimeService: WebSocket connected successfully');
            _isConnected = true;
            _isConnecting = false;
            if (!_connectionCompleter!.isCompleted) {
              _connectionCompleter!.complete();
            }
          },
          onStompError: (frame) {
            print('🔍 RealtimeService: STOMP error: ${frame.body}');
            _isConnected = false;
            _isConnecting = false;
            if (!_connectionCompleter!.isCompleted) {
              _connectionCompleter!.completeError(Exception('STOMP error: ${frame.body}'));
            }
          },
          onWebSocketError: (dynamic err) {
            print('🔍 RealtimeService: WebSocket error: $err');
            _isConnected = false;
            _isConnecting = false;
            if (!_connectionCompleter!.isCompleted) {
              _connectionCompleter!.completeError(err);
            }
          },
          onDisconnect: (frame) {
            print('🔍 RealtimeService: WebSocket disconnected');
            _isConnected = false;
            _isConnecting = false;
            _subscriptions.clear();
          },
          connectionTimeout: const Duration(seconds: 10),
          stompConnectHeaders: headers,
          webSocketConnectHeaders: headers,
          heartbeatIncoming: const Duration(seconds: 0),
          heartbeatOutgoing: const Duration(seconds: 0),
        ),
      );

      if (_client == null) {
        throw Exception('WebSocket client is null');
      }
      _client!.activate();
      await _connectionCompleter!.future;
    } catch (e) {
      _isConnecting = false;
      _connectionCompleter = null;
      rethrow;
    } finally {
      _isConnecting = false;
      _connectionCompleter = null;
    }
  }

  Future<void> subscribeToUserNotifications({
    required String userId,
    required RealtimeMessageHandler onMessage,
  }) async {
    _currentUserId = userId;
    await _ensureConnected();
    final destination = '/topic/user/$userId';
    if (_subscriptions.containsKey(destination)) return;

    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot subscribe to $destination');
      return;
    }
    
    final sub = _client!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final Map<String, dynamic> payload = jsonDecode(frame.body!);
          onMessage(payload);
        } catch (e) {
          print('🔍 RealtimeService: Error parsing user notification: $e');
        }
      },
    );

    _subscriptions[destination] = sub;
  }

  Future<void> subscribeToChat({
    required int chatId,
    required ChatMessageHandler onMessage,
  }) async {
    await _ensureConnected();
    final destination = '/topic/chat/$chatId';
    
    if (_subscriptions.containsKey(destination)) return;

    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot subscribe to chat $chatId');
      return;
    }

    final sub = _client!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final Map<String, dynamic> payload = jsonDecode(frame.body!);
          onMessage(payload);
        } catch (e) {
          print('🔍 RealtimeService: Error parsing chat message: $e');
        }
      },
    );

    _subscriptions[destination] = sub;
    _chatHandlers[destination] = onMessage;
  }

  Future<void> unsubscribeFromChat(int chatId) async {
    final destination = '/topic/chat/$chatId';
    _subscriptions[destination]?.call();
    _subscriptions.remove(destination);
    _chatHandlers.remove(destination);
  }

  Future<void> sendJoinChat(int chatId) async {
    await _ensureConnected();
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot send join chat message');
      return;
    }
    
    _client!.send(
      destination: '/app/chat.join',
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({'chatId': chatId}),
    );
  }

  Future<void> sendMessage({
    required int chatId,
    required String content,
  }) async {
    print('🔍 RealtimeService: Sending message to chat $chatId: $content');
    await _ensureConnected();
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    final messageData = {
      'chatId': chatId,
      'content': content,
    };
    
    print('🔍 RealtimeService: Sending to /app/chat.send with data: $messageData');
    
    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot send message');
      return;
    }
    
    _client!.send(
      destination: '/app/chat.send',
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode(messageData),
    );
    
    print('🔍 RealtimeService: Message sent via WebSocket');
  }

  Future<void> markMessagesAsRead({
    required int chatId,
  }) async {
    print('🔍 RealtimeService: Marking messages as read in chat $chatId');
    await _ensureConnected();
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    final messageData = {
      'chatId': chatId,
    };
    
    print('🔍 RealtimeService: Sending to /app/chat.markRead with data: $messageData');
    
    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot mark messages as read');
      return;
    }
    
    _client!.send(
      destination: '/app/chat.markRead',
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode(messageData),
    );
    
    print('🔍 RealtimeService: Mark read sent via WebSocket');
  }

  Future<void> sendLeaveChat() async {
    await _ensureConnected();
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    if (_client == null) {
      print('🔍 RealtimeService: Client is null, cannot send leave chat message');
      return;
    }
    
    _client!.send(
      destination: '/app/chat.leave',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> disconnect() async {
    print('🔍 RealtimeService: Disconnecting...');
    try {
      if (_client != null) {
        _client!.deactivate();
      }
    } catch (e) {
      print('🔍 RealtimeService: Error during disconnect: $e');
    } finally {
      _client = null;
      _isConnected = false;
      _isConnecting = false;
      _connectionCompleter = null;
      _subscriptions.clear();
      _chatHandlers.clear();
      _currentUserId = null;
      print('🔍 RealtimeService: Disconnect completed');
    }
  }

  /// Reconnect with fresh token (useful when token expires)
  Future<void> reconnect() async {
    await disconnect();
    if (_currentUserId != null) {
      final currentUserId = _currentUserId!; // Safe to use after null check
      // Re-subscribe to user notifications if we had a user
      await subscribeToUserNotifications(
        userId: currentUserId,
        onMessage: (payload) {
          // This will be overridden by the actual handler
        },
      );
    }
  }

  /// Handle app resume - check connection and reconnect if needed
  Future<void> handleAppResume() async {
    print('🔍 RealtimeService: Handling app resume');
    
    // Double-check authentication state during app resume
    // _currentUserId might have been cleared during disconnect or auth changes
    if (_currentUserId == null) {
      print('🔍 RealtimeService: No user ID available during app resume, skipping reconnection');
      return;
    }
    
    final currentUserId = _currentUserId!; // Safe to use after null check
    print('🔍 RealtimeService: App resumed, ensuring connection for user $currentUserId');
    
    try {
      // Force a fresh connection on app resume to handle any network changes
      // or connection drops that might have happened while backgrounded
      print('🔍 RealtimeService: Forcing reconnection after app resume for reliability');
      await disconnect();
      
      // Double-check user ID again after disconnect (disconnect clears _currentUserId)
      // We need to restore it for the reconnection
      _currentUserId = currentUserId;
      
      await _ensureConnected();
      
      // Re-subscribe to user notifications with fresh connection
      await subscribeToUserNotifications(
        userId: currentUserId,
        onMessage: (payload) {
          // This will be overridden by the actual handler in ChatService
        },
      );
      
      print('🔍 RealtimeService: Successfully handled app resume with fresh connection');
    } catch (e) {
      print('🔍 RealtimeService: Failed to handle app resume: $e');
      // Don't throw - this is not critical
    }
  }

  /// Handle app pause - gracefully handle disconnection
  Future<void> handleAppPause() async {
    print('🔍 RealtimeService: Handling app pause');
    // Don't disconnect immediately on pause - keep connection alive
    // The connection will be cleaned up when the app is actually closed
  }
}


