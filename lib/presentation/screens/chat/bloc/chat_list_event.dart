import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class ChatListLoad extends ChatListEvent {
  const ChatListLoad();
}

class ChatListRefresh extends ChatListEvent {
  const ChatListRefresh();
}

class ChatListCacheUpdate extends ChatListEvent {
  const ChatListCacheUpdate();
}

class ChatListUserChanged extends ChatListEvent {
  final String? userId;
  
  const ChatListUserChanged(this.userId);
  
  @override
  List<Object?> get props => [userId];
}
