import 'dart:async';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import '../../domain/models/chat_user.dart';
import '../../domain/models/send_message_request.dart';
import '../repositories/chat_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/ad_repository.dart';
import 'realtime_service.dart';
import 'notification_service.dart';
import 'datetime_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<int, Chat> _chats = {};
  final StreamController<List<Chat>> _chatsController = StreamController<List<Chat>>.broadcast();
  final Map<int, StreamController<Chat>> _chatControllers = {};

  ChatRepository? _chatRepository;
  UserRepository? _userRepository;
  AdRepository? _adRepository;
  RealtimeService? _realtimeService;
  NotificationService? _notificationService;
  final DateTimeService _dateTimeService = DateTimeService();
  
  Timer? _chatsNotificationTimer;
  int _notificationCount = 0;

  Stream<List<Chat>> get chatsStream => _chatsController.stream;

  void initialize({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
    required AdRepository adRepository,
    RealtimeService? realtimeService,
    NotificationService? notificationService,
  }) {
    _chatRepository = chatRepository;
    _userRepository = userRepository;
    _adRepository = adRepository;
    _realtimeService = realtimeService;
    _notificationService = notificationService;
  }

  Stream<Chat>? getChatStream(int chatId) {
    final controller = _chatControllers[chatId];
    print('🔍 ChatService: Getting stream for chat $chatId, controller exists: ${controller != null}');
    return controller?.stream;
  }

  List<Chat> get allChats => _chats.values.toList();

  /// Get or create a chat between buyer and seller for a specific ad
  Future<Chat> getOrCreateChat({
    required int adId,
    required String adTitle,
    required ChatUser buyer,
    required ChatUser seller,
  }) async {
    if (_chatRepository == null) {
      throw Exception('ChatService not initialized. Call initialize() first.');
    }

    try {
      // Create or get chat from backend
      final chatEntity = await _chatRepository!.createOrGetChat(
        adId: adId,
        sellerId: seller.id,
      );

      // Check if we already have this chat cached
      if (_chats.containsKey(chatEntity.id)) {
        final chat = _chats[chatEntity.id]!;
        _ensureStreamController(chatEntity.id);
        return chat;
      }

      // Create new chat from entity
      final chat = Chat.fromEntity(
        entity: chatEntity,
        adTitle: adTitle,
        buyer: buyer,
        seller: seller,
        messages: [],
      );

      _chats[chatEntity.id] = chat;
      _ensureStreamController(chatEntity.id);
      
      print('🔍 ChatService: Created new chat ${chatEntity.id} with stream controller');
      _notifyChatsChanged();
      _notifyChatChanged(chat);

      return chat;
    } catch (e) {
      print('🔍 ChatService: Error creating/getting chat: $e');
      rethrow;
    }
  }

  void _ensureStreamController(int chatId) {
    if (!_chatControllers.containsKey(chatId)) {
      print('🔍 ChatService: Creating stream controller for chat $chatId');
      _chatControllers[chatId] = StreamController<Chat>.broadcast();
      _subscribeToChatUpdates(chatId);
    } else {
      print('🔍 ChatService: Stream controller already exists for chat $chatId');
    }
  }

  void _subscribeToChatUpdates(int chatId) {
    if (_realtimeService == null) return;
    
    _realtimeService!.subscribeToChat(
      chatId: chatId,
      onMessage: (payload) {
        _handleRealtimeMessage(chatId, payload);
      },
    );
  }

  void _handleRealtimeMessage(int chatId, Map<String, dynamic> payload) {
    final type = payload['type'] as String?;
    if (type == 'NEW_MESSAGE') {
      final messageDataRaw = payload['message'];
      if (messageDataRaw == null || messageDataRaw is! Map) {
        print('🔍 ChatService: Invalid message data in realtime message');
        return;
      }
      
      final Map<String, dynamic> messageData = Map<String, dynamic>.from(messageDataRaw);
      
      // Parse timestamp with timezone correction
      DateTime timestamp;
      try {
        final timestampStr = messageData['timestamp'] as String?;
        if (timestampStr != null) {
          // Debug the timestamp before parsing
          _dateTimeService.debugTimestamp('Realtime message timestamp', timestampStr);
          timestamp = _dateTimeService.parseBackendTimestamp(timestampStr);
        } else {
          timestamp = DateTime.now();
        }
      } catch (e) {
        print('🔍 ChatService: Error parsing timestamp in realtime message: $e');
        timestamp = DateTime.now();
      }
      
      // Safely parse message data with null checks
      final messageId = messageData['id'];
      final messageChatId = messageData['chatId'];
      final senderId = messageData['senderId'];
      final content = messageData['content'];
      
      if (messageId == null || messageChatId == null || senderId == null || content == null) {
        print('🔍 ChatService: Missing required message fields in realtime message - id: $messageId, chatId: $messageChatId, senderId: $senderId, content: $content');
        return;
      }
      
      // Create Message object
      final message = Message(
        id: (messageId as num).toInt(),
        chatId: (messageChatId as num).toInt(),
        senderId: senderId as String,
        content: content as String,
        timestamp: timestamp,
        isRead: (messageData['isRead'] as bool?) ?? false,
      );

      // Update local chat
      final chat = _chats[chatId];
      if (chat != null) {
        final updatedMessages = [...chat.messages, message];
        final updatedChat = chat.copyWith(
          messages: updatedMessages,
          lastMessageAt: message.timestamp,
        );
        
        _chats[chatId] = updatedChat;
        _notifyChatChanged(updatedChat);
        _notifyChatsChanged();
      }
    }
  }

  /// Send a message to a chat
  Future<Message> sendMessage({
    required int chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    if (_realtimeService == null || _chatRepository == null) {
      throw Exception('ChatService not initialized. Call initialize() first.');
    }

    // Create optimistic message for immediate UI update
    final optimisticMessage = Message(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative ID to distinguish from real messages
      chatId: chatId,
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isRead: true, // Sent messages are considered read
    );

    // Update local chat optimistically first
    final chat = _chats[chatId];
    if (chat != null) {
      final updatedMessages = [...chat.messages, optimisticMessage];
      final updatedChat = chat.copyWith(
        messages: updatedMessages,
        lastMessageAt: optimisticMessage.timestamp,
      );

      _chats[chatId] = updatedChat;
      
      print('🔍 ChatService: Adding optimistic message to UI');
      _notifyChatChanged(updatedChat);
      _notifyChatsChanged();
    }

    try {
      // Try WebSocket first
      try {
        await _realtimeService!.sendMessage(
          chatId: chatId,
          content: content,
        );
        print('🔍 ChatService: Message sent via WebSocket');
        
        // WebSocket doesn't return a response, so we keep the optimistic message
        // The real message will come through the WebSocket subscription
        return optimisticMessage;
      } catch (wsError) {
        print('🔍 ChatService: WebSocket send failed: $wsError, falling back to HTTP');
        
        // Fallback to HTTP POST
        final messageEntity = await _chatRepository!.sendMessage(
          chatId: chatId,
          request: SendMessageRequest(content: content),
        );

        // Convert to Message model
        final realMessage = Message.fromEntity(messageEntity);

        // Update local chat with real message (replace optimistic one)
        if (chat != null) {
          final messagesWithoutOptimistic = chat.messages.where((m) => m.id != optimisticMessage.id).toList();
          final updatedMessages = [...messagesWithoutOptimistic, realMessage];
          final updatedChat = chat.copyWith(
            messages: updatedMessages,
            lastMessageAt: realMessage.timestamp,
          );

          _chats[chatId] = updatedChat;
          
          print('🔍 ChatService: Message sent via HTTP, updating with real message');
          _notifyChatChanged(updatedChat);
          _notifyChatsChanged();
        }

        return realMessage;
      }
    } catch (e) {
      print('🔍 ChatService: Error sending message: $e');
      
      // Remove optimistic message on error
      if (chat != null) {
        final messagesWithoutOptimistic = chat.messages.where((m) => m.id != optimisticMessage.id).toList();
        final updatedChat = chat.copyWith(messages: messagesWithoutOptimistic);
        _chats[chatId] = updatedChat;
        _notifyChatChanged(updatedChat);
        _notifyChatsChanged();
      }
      
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(int chatId, String userId) async {
    if (_realtimeService == null || _chatRepository == null) {
      throw Exception('ChatService not initialized. Call initialize() first.');
    }

    try {
      // Try WebSocket first
      try {
        await _realtimeService!.markMessagesAsRead(chatId: chatId);
        print('🔍 ChatService: Messages marked as read via WebSocket');
      } catch (wsError) {
        print('🔍 ChatService: WebSocket mark read failed: $wsError, falling back to HTTP');
        
        // Fallback to HTTP
        await _chatRepository!.markMessagesAsRead(chatId);
        print('🔍 ChatService: Messages marked as read via HTTP');
      }

      // Update local chat
      final chat = _chats[chatId];
      if (chat != null) {
        final updatedMessages = chat.messages.map((message) {
          if (message.senderId != userId && !message.isRead) {
            return message.copyWith(isRead: true);
          }
          return message;
        }).toList();

        final updatedChat = chat.copyWith(messages: updatedMessages);
        _chats[chatId] = updatedChat;
        
        _notifyChatChanged(updatedChat);
        _notifyChatsChanged();
      }
    } catch (e) {
      print('🔍 ChatService: Error marking messages as read: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Connect realtime notifications for the given user
  Future<void> connectUserRealtime(String userId) async {
    if (_realtimeService == null) {
      print('🔍 ChatService: RealtimeService is null, cannot connect user realtime');
      return;
    }
    
    try {
      print('🔍 ChatService: Connecting user realtime for userId: $userId');
      await _realtimeService!.subscribeToUserNotifications(
        userId: userId,
        onMessage: (payload) {
          _handleUserNotification(payload);
        },
      );
    } catch (e) {
      print('🔍 ChatService: Failed to connect realtime: $e');
      // Don't rethrow - this is not critical for basic functionality
    }
  }

  void _handleUserNotification(Map<String, dynamic> payload) {
    print('🔍 ChatService: Received user notification: $payload');
    
    final type = payload['type'] as String?;
    
    switch (type) {
      case 'NEW_MESSAGE':
        _handleNewMessageNotification(payload);
        break;
      case 'UNREAD_COUNT_UPDATE':
        _handleUnreadCountUpdate(payload);
        break;
      default:
        print('🔍 ChatService: Unknown notification type: $type');
    }
  }

  void _handleNewMessageNotification(Map<String, dynamic> payload) {
    final chatId = payload['chatId'] as int?;
    final messageData = payload['message'] as Map<String, dynamic>?;
    
    if (chatId == null || messageData == null) {
      print('🔍 ChatService: Invalid NEW_MESSAGE notification data - chatId: $chatId, messageData: $messageData');
      return;
    }

    // Parse timestamp with timezone correction
    DateTime timestamp;
    try {
      final timestampStr = messageData['timestamp'] as String?;
      if (timestampStr != null) {
        // Debug the timestamp before parsing
        _dateTimeService.debugTimestamp('User notification timestamp', timestampStr);
        timestamp = _dateTimeService.parseBackendTimestamp(timestampStr);
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      print('🔍 ChatService: Error parsing timestamp: $e');
      timestamp = DateTime.now();
    }
    
    // Safely parse message data with null checks
    final messageId = messageData['id'];
    final senderId = messageData['senderId'];
    final content = messageData['content'];
    
    if (messageId == null || senderId == null || content == null) {
      print('🔍 ChatService: Missing required message fields - id: $messageId, senderId: $senderId, content: $content');
      return;
    }
    
    // Create Message object - use chatId from payload level, not from message data
    final message = Message(
      id: (messageId as num).toInt(),
      chatId: chatId,
      senderId: senderId as String,
      content: content as String,
      timestamp: timestamp,
      isRead: (messageData['isRead'] as bool?) ?? false,
    );

    // Update local chat if it exists
    final chat = _chats[chatId];
    if (chat != null) {
      final updatedMessages = [...chat.messages, message];
      final updatedChat = chat.copyWith(
        messages: updatedMessages,
        lastMessageAt: message.timestamp,
      );
      
      _chats[chatId] = updatedChat;
      _notifyChatChanged(updatedChat);
      _notifyChatsChanged();
      
      print('🔍 ChatService: Updated existing chat $chatId with new message');
    } else {
      // Chat doesn't exist locally, we need to load it
      print('🔍 ChatService: Received message for unknown chat $chatId, will load on next chat list refresh');
    }

    // Show local notification
    _showMessageNotification(chatId, message, chat);
  }

  void _showMessageNotification(int chatId, Message message, Chat? chat) {
    if (_notificationService == null) return;

    // Get sender name - try to get from chat, otherwise use sender ID
    String senderName = 'Unknown';
    if (chat != null) {
      if (chat.buyer.id == message.senderId) {
        senderName = chat.buyer.name;
      } else if (chat.seller.id == message.senderId) {
        senderName = chat.seller.name;
      }
    }

    // Get chat title - use ad title if available, otherwise fallback
    String chatTitle = chat?.adTitle ?? 'New Message';

    _notificationService!.showMessageNotification(
      title: chatTitle,
      body: '$senderName: ${message.content}',
      chatId: chatId,
    );
  }

  void _handleUnreadCountUpdate(Map<String, dynamic> payload) {
    final unreadCount = payload['unreadCount'] as int?;
    if (unreadCount != null) {
      print('🔍 ChatService: Unread count updated to $unreadCount');
      print('🔍 ChatService: Current chats in cache: ${_chats.keys.toList()}');
      print('🔍 ChatService: Total chats: ${_chats.length}');
      
      // Trigger a refresh of the chat list to update UI
      _notifyChatsChanged();
    }
  }

  Future<void> joinChat(int chatId) async {
    if (_realtimeService == null) return;
    try {
      await _realtimeService!.sendJoinChat(chatId);
    } catch (e) {
      print('🔍 ChatService: Failed to join chat $chatId: $e');
      // Don't rethrow - this is not critical for basic functionality
    }
  }

  Future<void> leaveChat() async {
    if (_realtimeService == null) return;
    try {
      await _realtimeService!.sendLeaveChat();
    } catch (e) {
      print('🔍 ChatService: Failed to leave chat: $e');
      // Don't rethrow - this is not critical for basic functionality
    }
  }

  /// Get a specific chat by ID
  Chat? getChat(int chatId) {
    final chat = _chats[chatId];
    print('🔍 ChatService: Getting chat $chatId, found: ${chat != null}');
    if (chat != null) {
      print('🔍 ChatService: Chat has ${chat.messages.length} messages');
    } else {
      print('🔍 ChatService: Available chats: ${_chats.keys.toList()}');
    }
    return chat;
  }

  /// Get chats for a specific user
  List<Chat> getUserChats(String userId) {
    print('🔍 ChatService: Getting chats for user $userId');
    print('🔍 ChatService: Total chats in cache: ${_chats.length}');
    print('🔍 ChatService: Available chat IDs: ${_chats.keys.toList()}');
    
    // Debug: Print all chat details
    for (final chat in _chats.values) {
      print('🔍 ChatService: Chat ${chat.id} - buyer: ${chat.buyer.id}, seller: ${chat.seller.id}');
      print('🔍 ChatService: User ID match - buyer: ${chat.buyer.id == userId}, seller: ${chat.seller.id == userId}');
    }
    
    final userChats = _chats.values
        .where((chat) => chat.buyer.id == userId || chat.seller.id == userId)
        .toList();
    
    print('🔍 ChatService: Found ${userChats.length} chats for user $userId');
    for (final chat in userChats) {
      print('🔍 ChatService: Chat ${chat.id} - buyer: ${chat.buyer.id}, seller: ${chat.seller.id}, messages: ${chat.messages.length}');
    }
    
    return userChats;
  }

  /// Load user chats from backend
  Future<List<Chat>> loadUserChats() async {
    if (_chatRepository == null || _userRepository == null || _adRepository == null) {
      print('🔍 ChatService: Service not initialized - chatRepository: ${_chatRepository != null}, userRepository: ${_userRepository != null}, adRepository: ${_adRepository != null}');
      throw Exception('ChatService not initialized. Call initialize() first.');
    }

    try {
      print('🔍 ChatService: Loading user chats from backend...');
      final chatEntities = await _chatRepository!.getUserChats();
      print('🔍 ChatService: Received ${chatEntities.length} chat entities from backend');
      
      final chats = <Chat>[];

      for (final entity in chatEntities) {
        print('🔍 ChatService: Processing chat entity ${entity.id} - buyerId: ${entity.buyerId}, sellerId: ${entity.sellerId}');
        
        // Get user details for buyer and seller
        final buyerData = await _userRepository!.getUser(entity.buyerId);
        final sellerData = await _userRepository!.getUser(entity.sellerId);
        
        print('🔍 ChatService: Buyer data: $buyerData');
        print('🔍 ChatService: Seller data: $sellerData');
        print('🔍 ChatService: Buyer ID from entity: ${entity.buyerId}');
        print('🔍 ChatService: Seller ID from entity: ${entity.sellerId}');
        
        final buyer = ChatUser.fromJson(buyerData);
        final seller = ChatUser.fromJson(sellerData);
        
        print('🔍 ChatService: Parsed buyer ID: ${buyer.id}');
        print('🔍 ChatService: Parsed seller ID: ${seller.id}');

        // Get messages for this chat
        final messageEntities = await _chatRepository!.getChatMessages(entity.id);
        final messages = messageEntities.map((e) => Message.fromEntity(e)).toList();

        // Fetch the actual ad title
        String adTitle = 'Car Ad ${entity.adId}'; // Fallback title
        try {
          final ad = await _adRepository!.getAd(entity.adId);
          adTitle = '${ad.make} ${ad.model} ${ad.title}';
          print('🔍 ChatService: Fetched ad title: $adTitle for ad ID: ${entity.adId}');
        } catch (e) {
          print('🔍 ChatService: Failed to fetch ad title for ad ${entity.adId}: $e');
          // Keep the fallback title
        }

        final chat = Chat.fromEntity(
          entity: entity,
          adTitle: adTitle,
          buyer: buyer,
          seller: seller,
          messages: messages,
        );

        print('🔍 ChatService: Created chat ${chat.id} with buyer ${chat.buyer.id} and seller ${chat.seller.id}');
        
        chats.add(chat);
        _chats[entity.id] = chat;
        _ensureStreamController(entity.id);
      }

      print('🔍 ChatService: Loaded ${chats.length} chats, notifying listeners...');
      _notifyChatsChanged();
      return chats;
    } catch (e) {
      print('🔍 ChatService: Error loading user chats: $e');
      rethrow;
    }
  }


  void _unsubscribeFromChat(int chatId) {
    if (_realtimeService != null) {
      _realtimeService!.unsubscribeFromChat(chatId);
    }
  }

  /// Notify listeners that chats have changed (with debouncing)
  void _notifyChatsChanged() {
    _notificationCount++;
    print('🔍 ChatService: _notifyChatsChanged called #$_notificationCount times');
    print('🔍 ChatService: Current chats count: ${_chats.length}');
    print('🔍 ChatService: Chats: ${_chats.keys.toList()}');
    
    // Cancel existing timer
    _chatsNotificationTimer?.cancel();
    
    // Set a new timer to debounce notifications
    _chatsNotificationTimer = Timer(const Duration(milliseconds: 100), () {
      if (!_chatsController.isClosed) {
        final chatsList = _chats.values.toList();
        print('🔍 ChatService: Actually sending chats notification (debounced) with ${chatsList.length} chats');
        for (final chat in chatsList) {
          print('🔍 ChatService: Chat ${chat.id} - unread count: ${chat.getUnreadCount(chat.buyer.id)} (buyer) / ${chat.getUnreadCount(chat.seller.id)} (seller)');
        }
        _chatsController.add(chatsList);
      }
    });
  }

  /// Notify listeners that a specific chat has changed
  void _notifyChatChanged(Chat chat) {
    final controller = _chatControllers[chat.id];
    print('🔍 ChatService: Notifying chat ${chat.id} with ${chat.messages.length} messages');
    print('🔍 ChatService: Available controllers: ${_chatControllers.keys.toList()}');
    if (controller != null && !controller.isClosed) {
      print('🔍 ChatService: Stream controller found and active, sending update');
      controller.add(chat);
      print('🔍 ChatService: Update sent to stream controller');
    } else {
      print('🔍 ChatService: No stream controller found or controller is closed for chat ${chat.id}');
      print('🔍 ChatService: Controller exists: ${controller != null}, isClosed: ${controller?.isClosed}');
    }
  }


  /// Clear all chats and unsubscribe from WebSocket topics (call this when user logs out)
  void clearAllChats() {
    print('🔍 ChatService: Clearing all chats and unsubscribing from WebSocket topics');
    
    // Unsubscribe from all chat topics
    for (final chatId in _chats.keys) {
      _unsubscribeFromChat(chatId);
    }
    
    // Close all stream controllers
    for (final controller in _chatControllers.values) {
      controller.close();
    }
    _chatControllers.clear();
    
    // Clear all chats
    _chats.clear();
    
    // Notify listeners
    _notifyChatsChanged();
  }

  /// Dispose of resources
  void dispose() {
    _chatsNotificationTimer?.cancel();
    _chatsController.close();
    for (final controller in _chatControllers.values) {
      controller.close();
    }
    _chatControllers.clear();
    _chats.clear();
  }
}
