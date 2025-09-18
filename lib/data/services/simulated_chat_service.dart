import 'dart:async';
import 'dart:math';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import '../../domain/models/chat_user.dart';

/// Simulated chat service that demonstrates how real-time chat would work
/// This is a proof-of-concept for in-memory chat with simulated real-time updates
class SimulatedChatService {
  static final SimulatedChatService _instance = SimulatedChatService._internal();
  factory SimulatedChatService() => _instance;
  SimulatedChatService._internal();

  final Map<String, Chat> _chats = {};
  final Map<String, DateTime> _chatExpiry = {};
  final StreamController<List<Chat>> _chatsController = StreamController<List<Chat>>.broadcast();
  final Map<String, StreamController<Chat>> _chatControllers = {};

  // 14 days in milliseconds
  static const Duration _expirationDuration = Duration(days: 14);

  Stream<List<Chat>> get chatsStream => _chatsController.stream;
  Stream<Chat>? getChatStream(String chatId) => _chatControllers[chatId]?.stream;
  List<Chat> get allChats => _chats.values.toList();

  /// Get or create a chat between buyer and seller for a specific ad
  Future<Chat> getOrCreateChat({
    required String adId,
    required String adTitle,
    required ChatUser buyer,
    required ChatUser seller,
  }) async {
    final chatId = _generateChatId(adId, buyer.id, seller.id);
    
    if (_chats.containsKey(chatId)) {
      final chat = _chats[chatId]!;
      _updateChatExpiry(chatId);
      if (!_chatControllers.containsKey(chatId)) {
        _chatControllers[chatId] = StreamController<Chat>.broadcast();
      }
      return chat;
    }

    final chat = Chat(
      id: int.parse(chatId.replaceAll('chat_', '')),
      adId: int.parse(adId),
      adTitle: adTitle,
      buyer: buyer,
      seller: seller,
      messages: [],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );

    _chats[chatId] = chat;
    _updateChatExpiry(chatId);
    _chatControllers[chatId] = StreamController<Chat>.broadcast();
    
    _notifyChatsChanged();
    _notifyChatChanged(chat);

    return chat;
  }

  /// Send a message to a chat
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final chat = _chats[chatId];
    if (chat == null) {
      throw Exception('Chat not found');
    }

    final message = Message(
      id: int.parse(_generateMessageId().replaceAll('msg_', '')),
      chatId: int.parse(chatId.replaceAll('chat_', '')),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );

    final updatedMessages = [...chat.messages, message];
    final updatedChat = chat.copyWith(
      messages: updatedMessages,
      lastMessageAt: message.timestamp,
    );

    _chats[chatId] = updatedChat;
    _updateChatExpiry(chatId);
    
    print('🔍 SimulatedChatService: Message sent, notifying listeners');
    _notifyChatChanged(updatedChat);
    _notifyChatsChanged();

    // Simulate real-time update for other users
    _simulateRealTimeUpdate(updatedChat);

    return message;
  }

  /// Simulate real-time updates by adding a delay and notifying again
  /// This demonstrates how real-time messaging would work
  void _simulateRealTimeUpdate(Chat chat) {
    Timer(const Duration(milliseconds: 500), () {
      print('🔍 SimulatedChatService: Simulating real-time update for chat ${chat.id}');
      _notifyChatChanged(chat);
    });
  }

  /// Get a specific chat by ID
  Chat? getChat(String chatId) {
    final chat = _chats[chatId];
    if (chat != null) {
      _updateChatExpiry(chatId);
    }
    return chat;
  }

  /// Get chats for a specific user
  List<Chat> getUserChats(String userId) {
    final userChats = _chats.values
        .where((chat) => chat.buyer.id == userId || chat.seller.id == userId)
        .toList();
    
    for (final chat in userChats) {
      _updateChatExpiry('chat_${chat.id}');
    }
    
    return userChats;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final chat = _chats[chatId];
    if (chat == null) return;

    final updatedMessages = chat.messages.map((message) {
      if (message.senderId != userId && !message.isRead) {
        return message.copyWith(isRead: true);
      }
      return message;
    }).toList();

    final updatedChat = chat.copyWith(messages: updatedMessages);
    _chats[chatId] = updatedChat;
    _updateChatExpiry(chatId);
    
    _notifyChatChanged(updatedChat);
    _notifyChatsChanged();
  }

  /// Generate a unique chat ID
  String _generateChatId(String adId, String buyerId, String sellerId) {
    final participants = [buyerId, sellerId]..sort();
    return 'chat_${adId}_${participants.join('_')}';
  }

  /// Generate a unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Update chat expiry time
  void _updateChatExpiry(String chatId) {
    _chatExpiry[chatId] = DateTime.now().add(_expirationDuration);
  }

  /// Notify listeners that chats have changed
  void _notifyChatsChanged() {
    if (!_chatsController.isClosed) {
      _chatsController.add(_chats.values.toList());
    }
  }

  /// Notify listeners that a specific chat has changed
  void _notifyChatChanged(Chat chat) {
    final controller = _chatControllers[chat.id];
    if (controller != null && !controller.isClosed) {
      controller.add(chat);
    }
  }

  /// Start periodic cleanup of expired chats
  void startCleanupTimer() {
    Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupExpiredChats();
    });
  }

  /// Clean up expired chats
  void _cleanupExpiredChats() {
    final now = DateTime.now();
    final expiredChatIds = <String>[];

    for (final entry in _chatExpiry.entries) {
      if (now.isAfter(entry.value)) {
        expiredChatIds.add(entry.key);
      }
    }

    for (final chatId in expiredChatIds) {
      _chats.remove(chatId);
      _chatExpiry.remove(chatId);
      _chatControllers[chatId]?.close();
      _chatControllers.remove(chatId);
    }

    if (expiredChatIds.isNotEmpty) {
      _notifyChatsChanged();
    }
  }

  /// Dispose of resources
  void dispose() {
    _chatsController.close();
    for (final controller in _chatControllers.values) {
      controller.close();
    }
    _chatControllers.clear();
    _chats.clear();
    _chatExpiry.clear();
  }
}
