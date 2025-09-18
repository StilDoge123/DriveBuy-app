import 'package:equatable/equatable.dart';
import '../../data/services/datetime_service.dart';

class MessageEntity extends Equatable {
  final int id;
  final int chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    final dateTimeService = DateTimeService();
    return MessageEntity(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: dateTimeService.parseBackendTimestamp(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  @override
  List<Object?> get props => [id, chatId, senderId, content, timestamp, isRead];
}
