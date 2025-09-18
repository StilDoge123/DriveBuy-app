import 'package:equatable/equatable.dart';

abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends AiAssistantEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class ResetChatEvent extends AiAssistantEvent {}

class InitializeService extends AiAssistantEvent {
  const InitializeService();
}

class InitializeServiceDone extends AiAssistantEvent {
  final dynamic service;
  const InitializeServiceDone(this.service);
  @override
  List<Object> get props => [service];
}

class InitializeServiceError extends AiAssistantEvent {
  final String error;
  const InitializeServiceError(this.error);
  @override
  List<Object> get props => [error];
} 