import 'package:equatable/equatable.dart';

abstract class IndividualChatEvent extends Equatable {
  const IndividualChatEvent();

  @override
  List<Object?> get props => [];
}

class IndividualChatLoad extends IndividualChatEvent {
  final int chatId;

  const IndividualChatLoad(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class IndividualChatSendMessage extends IndividualChatEvent {
  final int chatId;
  final String content;

  const IndividualChatSendMessage({
    required this.chatId,
    required this.content,
  });

  @override
  List<Object?> get props => [chatId, content];
}

class IndividualChatMarkAsRead extends IndividualChatEvent {
  final int chatId;

  const IndividualChatMarkAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class IndividualChatNavigateToAdDetails extends IndividualChatEvent {
  final int adId;

  const IndividualChatNavigateToAdDetails(this.adId);

  @override
  List<Object?> get props => [adId];
}
