import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/ai_assistant_service.dart';
import '../../../../domain/models/car_search_filter.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  AiAssistantService? _aiAssistantService;

  AiAssistantBloc({required Future<AiAssistantService> aiAssistantServiceFuture})
      : super(const AiAssistantState(status: AiAssistantStatus.initializing)) {
    on<InitializeService>(_onInitializeService);
    on<SendMessageEvent>(_onSendMessage);
    on<ResetChatEvent>(_onResetChat);
    // Start initialization
    add(const InitializeService());
    aiAssistantServiceFuture.then((service) {
      add(InitializeServiceDone(service));
    }).catchError((e) {
      add(InitializeServiceError(e.toString()));
    });
    on<InitializeServiceDone>(_onInitializeServiceDone);
    on<InitializeServiceError>(_onInitializeServiceError);
  }

  void _onResetChat(ResetChatEvent event, Emitter<AiAssistantState> emit) {
    emit(const AiAssistantState());
  }

  void _onInitializeService(InitializeService event, Emitter<AiAssistantState> emit) {
    emit(state.copyWith(status: AiAssistantStatus.initializing));
  }

  void _onInitializeServiceDone(InitializeServiceDone event, Emitter<AiAssistantState> emit) {
    _aiAssistantService = event.service;
    emit(state.copyWith(status: AiAssistantStatus.initial));
  }

  void _onInitializeServiceError(InitializeServiceError event, Emitter<AiAssistantState> emit) {
    emit(state.copyWith(status: AiAssistantStatus.failure, error: event.error));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<AiAssistantState> emit) async {
    if (_aiAssistantService == null) {
      emit(state.copyWith(
        status: AiAssistantStatus.failure,
        error: 'AI Assistant is still initializing.',
      ));
      return;
    }
    final userMessage = ChatMessage(text: event.message, isUser: true);
    emit(state.copyWith(
      status: AiAssistantStatus.loading,
      messages: [...state.messages, userMessage],
      searchFilter: null,
    ));

    try {
      final aiResponse = await _aiAssistantService!.sendMessage(
          message: event.message, history: state.messages);

      if (aiResponse.contains('---')) {
        final parts = aiResponse.split('---');
        final message = parts[0].trim();
        var filterJson = parts[1].trim();

        if (filterJson.startsWith('```json')) {
          filterJson = filterJson.substring(7);
          if (filterJson.endsWith('```')) {
            filterJson = filterJson.substring(0, filterJson.length - 3);
          }
        }

        final filter = CarSearchFilter.fromJson(jsonDecode(filterJson));
        final aiMessage = ChatMessage(text: message, isUser: false);
        emit(state.copyWith(
          status: AiAssistantStatus.success,
          messages: [...state.messages, aiMessage],
          searchFilter: filter,
        ));
      } else {
        final aiMessage = ChatMessage(text: aiResponse, isUser: false);
        emit(state.copyWith(
          status: AiAssistantStatus.success,
          messages: [...state.messages, aiMessage],
          searchFilter: null,
        ));
      }
    } catch (e) {
      final errorMessage = ChatMessage(text: e.toString(), isUser: false);
      emit(state.copyWith(
        status: AiAssistantStatus.failure,
        messages: [...state.messages, errorMessage],
        error: e.toString(),
        searchFilter: null,
      ));
    }
  }
} 