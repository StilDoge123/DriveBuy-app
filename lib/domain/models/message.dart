import 'package:equatable/equatable.dart';
import 'message_entity.dart';
import '../../data/services/datetime_service.dart';

class Message extends Equatable {
  final int id;
  final int chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final dateTimeService = DateTimeService();
    return Message(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: dateTimeService.parseBackendTimestamp(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// Create a Message from MessageEntity
  factory Message.fromEntity(MessageEntity entity) {
    return Message(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      content: entity.content,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
    };
  }

  Message copyWith({
    int? id,
    int? chatId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, chatId, senderId, content, timestamp, type, isRead];
}

enum MessageType {
  text,
  image,
  system,
}
