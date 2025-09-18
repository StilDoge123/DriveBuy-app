import 'package:equatable/equatable.dart';
import 'package:drivebuy/domain/models/car_search_filter.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  List<Object?> get props => [text, isUser];
}

enum AiAssistantStatus { initial, initializing, loading, success, failure }

class AiAssistantState extends Equatable {
  const AiAssistantState({
    this.status = AiAssistantStatus.initial,
    this.messages = const [],
    this.error = '',
    this.searchFilter,
  });

  final AiAssistantStatus status;
  final List<ChatMessage> messages;
  final String error;
  final CarSearchFilter? searchFilter;

  AiAssistantState copyWith({
    AiAssistantStatus? status,
    List<ChatMessage>? messages,
    String? error,
    CarSearchFilter? searchFilter,
  }) {
    return AiAssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
      searchFilter: searchFilter ?? this.searchFilter,
    );
  }

  @override
  List<Object?> get props => [status, messages, error, searchFilter];
} 