import 'package:equatable/equatable.dart';
import 'message.dart';
import 'chat_user.dart';
import 'chat_entity.dart';
import '../../data/services/datetime_service.dart';

class Chat extends Equatable {
  final int id;
  final int adId;
  final String adTitle;
  final ChatUser buyer;
  final ChatUser seller;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  const Chat({
    required this.id,
    required this.adId,
    required this.adTitle,
    required this.buyer,
    required this.seller,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final dateTimeService = DateTimeService();
    return Chat(
      id: json['id'] as int,
      adId: json['adId'] as int,
      adTitle: json['adTitle'] as String? ?? '',
      buyer: ChatUser.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: ChatUser.fromJson(json['seller'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: dateTimeService.parseBackendTimestamp(json['createdAt'] as String),
      lastMessageAt: dateTimeService.parseBackendTimestamp(json['lastMessageAt'] as String),
    );
  }

  /// Create a Chat from ChatEntity and additional data
  factory Chat.fromEntity({
    required ChatEntity entity,
    required String adTitle,
    required ChatUser buyer,
    required ChatUser seller,
    List<Message> messages = const [],
  }) {
    return Chat(
      id: entity.id,
      adId: entity.adId,
      adTitle: adTitle,
      buyer: buyer,
      seller: seller,
      messages: messages,
      createdAt: entity.createdAt,
      lastMessageAt: entity.lastMessageAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adId': adId,
      'adTitle': adTitle,
      'buyer': buyer.toJson(),
      'seller': seller.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
  }

  Chat copyWith({
    int? id,
    int? adId,
    String? adTitle,
    ChatUser? buyer,
    ChatUser? seller,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return Chat(
      id: id ?? this.id,
      adId: adId ?? this.adId,
      adTitle: adTitle ?? this.adTitle,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  String getOtherUserId(String currentUserId) {
    return buyer.id == currentUserId ? seller.id : buyer.id;
  }

  ChatUser getOtherUser(String currentUserId) {
    return buyer.id == currentUserId ? seller : buyer;
  }

  int getUnreadCount(String currentUserId) {
    return messages.where((m) => m.senderId != currentUserId && !m.isRead).length;
  }

  @override
  List<Object?> get props => [
        id,
        adId,
        adTitle,
        buyer,
        seller,
        messages,
        createdAt,
        lastMessageAt,
      ];
}
