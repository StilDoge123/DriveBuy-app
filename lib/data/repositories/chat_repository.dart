import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/api_config.dart';
import '../../domain/models/chat_entity.dart';
import '../../domain/models/message_entity.dart';
import '../../domain/models/send_message_request.dart';

class ChatRepository {
  final String baseUrl;
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  ChatRepository({
    String? baseUrl,
    required Dio dio,
    FirebaseAuth? firebaseAuth,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _dio = dio,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<Response> _getWithAuth(String url) async {
    try {
      print('🔍 ChatRepository: Making GET request to: $url');
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Failed to get authentication token');
      }
      final response = await _dio.get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      print('🔍 ChatRepository: GET Response received: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔍 ChatRepository: Error in _getWithAuth: ${e.toString()}');
      rethrow;
    }
  }

  Future<Response> _postWithAuth(String url, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('🔍 ChatRepository: Making POST request to: $url');
      print('🔍 ChatRepository: Data: $data');
      print('🔍 ChatRepository: Query parameters: $queryParameters');
      
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Failed to get authentication token');
      }
      
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      print('🔍 ChatRepository: POST Response received: ${response.statusCode}');
      print('🔍 ChatRepository: POST Response headers: ${response.headers}');
      print('🔍 ChatRepository: POST Response data: ${response.data}');
      return response;
    } catch (e) {
      print('🔍 ChatRepository: Error in _postWithAuth: ${e.toString()}');
      rethrow;
    }
  }

  /// Create or get a chat for an ad
  Future<ChatEntity> createOrGetChat({
    required int adId,
    required String sellerId,
  }) async {
    print('🔍 ChatRepository: Creating chat for adId: $adId, sellerId: $sellerId');
    final response = await _postWithAuth(
      '$baseUrl/chats/create',
      queryParameters: {
        'adId': adId,
        'sellerId': sellerId,
      },
    );

    print('🔍 ChatRepository: Chat creation response: ${response.statusCode}');
    print('🔍 ChatRepository: Response headers: ${response.headers}');
    print('🔍 ChatRepository: Response data type: ${response.data.runtimeType}');
    print('🔍 ChatRepository: Response data: ${response.data}');
    
    if (response.statusCode == 200) {
      try {
        final chatEntity = ChatEntity.fromJson(response.data);
        print('🔍 ChatRepository: Successfully parsed ChatEntity: ${chatEntity.id}');
        return chatEntity;
      } catch (e) {
        print('🔍 ChatRepository: Error parsing ChatEntity: $e');
        print('🔍 ChatRepository: Raw response data: ${response.data}');
        rethrow;
      }
    } else {
      print('🔍 ChatRepository: Chat creation failed with status: ${response.statusCode}');
      print('🔍 ChatRepository: Response data: ${response.data}');
      throw Exception('Failed to create or get chat: ${response.statusCode}');
    }
  }

  /// Get all chats for the current user
  Future<List<ChatEntity>> getUserChats() async {
    final response = await _getWithAuth('$baseUrl/chats/list');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => ChatEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get user chats: ${response.statusCode}');
    }
  }

  /// Get a specific chat by ID
  Future<ChatEntity> getChatById(int chatId) async {
    final response = await _getWithAuth('$baseUrl/chats/$chatId');

    if (response.statusCode == 200) {
      return ChatEntity.fromJson(response.data);
    } else {
      throw Exception('Failed to get chat: ${response.statusCode}');
    }
  }

  /// Get messages for a specific chat
  Future<List<MessageEntity>> getChatMessages(int chatId) async {
    final response = await _getWithAuth('$baseUrl/chats/$chatId/messages');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => MessageEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get chat messages: ${response.statusCode}');
    }
  }

  /// Send a message to a chat
  Future<MessageEntity> sendMessage({
    required int chatId,
    required SendMessageRequest request,
  }) async {
    final response = await _postWithAuth(
      '$baseUrl/chats/$chatId/messages',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      return MessageEntity.fromJson(response.data);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  /// Mark messages as read in a chat
  Future<void> markMessagesAsRead(int chatId) async {
    final response = await _postWithAuth('$baseUrl/chats/$chatId/mark-read');

    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as read: ${response.statusCode}');
    }
  }

  /// Get unread message count for all chats
  Future<int> getUnreadMessageCount() async {
    final response = await _getWithAuth('$baseUrl/chats/unread-count');

    if (response.statusCode == 200) {
      return response.data['unreadCount'] as int;
    } else {
      throw Exception('Failed to get unread message count: ${response.statusCode}');
    }
  }

  /// Get unread message count for a specific chat
  Future<int> getUnreadMessageCountForChat(int chatId) async {
    final response = await _getWithAuth('$baseUrl/chats/$chatId/unread-count');

    if (response.statusCode == 200) {
      return response.data['unreadCount'] as int;
    } else {
      throw Exception('Failed to get unread message count for chat: ${response.statusCode}');
    }
  }

  /// Get chats for a specific ad
  Future<List<ChatEntity>> getChatsByAdId(int adId) async {
    final response = await _getWithAuth('$baseUrl/chats/ad/$adId');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => ChatEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get chats by ad ID: ${response.statusCode}');
    }
  }
}
