import 'package:equatable/equatable.dart';
import '../../data/services/datetime_service.dart';

class ChatEntity extends Equatable {
  final int id;
  final int adId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  const ChatEntity({
    required this.id,
    required this.adId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    final dateTimeService = DateTimeService();
    return ChatEntity(
      id: json['id'] as int,
      adId: json['adId'] as int,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      createdAt: dateTimeService.parseBackendTimestamp(json['createdAt'] as String),
      lastMessageAt: dateTimeService.parseBackendTimestamp(json['lastMessageAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adId': adId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, adId, buyerId, sellerId, createdAt, lastMessageAt];
}
