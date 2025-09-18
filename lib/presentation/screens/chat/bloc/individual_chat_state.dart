import 'package:equatable/equatable.dart';
import '../../../../domain/models/chat.dart';

abstract class IndividualChatState extends Equatable {
  const IndividualChatState();

  @override
  List<Object?> get props => [];
}

class IndividualChatInitial extends IndividualChatState {
  const IndividualChatInitial();
}

class IndividualChatLoading extends IndividualChatState {
  const IndividualChatLoading();
}

class IndividualChatLoaded extends IndividualChatState {
  final Chat chat;

  const IndividualChatLoaded(this.chat);

  @override
  List<Object?> get props => [chat];
}

class IndividualChatError extends IndividualChatState {
  final String message;

  const IndividualChatError(this.message);

  @override
  List<Object?> get props => [message];
}
