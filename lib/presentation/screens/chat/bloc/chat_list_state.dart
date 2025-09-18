import 'package:equatable/equatable.dart';
import '../../../../domain/models/chat.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;
  final bool isRefreshing;

  const ChatListLoaded(this.chats, {this.isRefreshing = false});

  @override
  List<Object?> get props => [chats, isRefreshing];
}

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
