import 'dart:async';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/services/chat_service.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/chat.dart';
import 'individual_chat_event.dart';
import 'individual_chat_state.dart';

class IndividualChatBloc extends Bloc<IndividualChatEvent, IndividualChatState> {
  final ChatService _chatService;
  StreamSubscription<Chat>? _chatSubscription;
  String? _currentUserId;
  final GoRouter _router;

  IndividualChatBloc({
    required ChatService chatService,
    required UserRepository userRepository,
    required GoRouter router,
  })  : _chatService = chatService,
        _router = router,
        super(const IndividualChatInitial()) {
    on<IndividualChatLoad>(_onChatLoad);
    on<IndividualChatSendMessage>(_onChatSendMessage);
    on<IndividualChatMarkAsRead>(_onChatMarkAsRead);
    on<IndividualChatNavigateToAdDetails>((event, emit) {
      _router.pushNamed(Routes.adDetails.name, pathParameters: {'id': event.adId.toString()});
    });
  }

  Future<void> _onChatLoad(IndividualChatLoad event, Emitter<IndividualChatState> emit) async {
    emit(const IndividualChatLoading());

    try {
      // Get current user ID from Firebase Auth
      final firebaseUser = FirebaseAuth.instance.currentUser;
      _currentUserId = firebaseUser?.uid;
      print('🔍 IndividualChatBloc: Current user ID: $_currentUserId');
      
      final chat = _chatService.getChat(event.chatId);
      if (chat != null) {
        emit(IndividualChatLoaded(chat));
        
        if (_currentUserId != null) {
          await _chatService.connectUserRealtime(_currentUserId!);
        }
        await _chatService.joinChat(event.chatId);

        // Listen for individual chat updates
        _chatSubscription?.cancel();
        final stream = _chatService.getChatStream(event.chatId);
        print('🔍 IndividualChatBloc: Setting up stream subscription for chat ${event.chatId}, stream exists: ${stream != null}');
        _chatSubscription = stream?.listen(
          (updatedChat) {
            print('🔍 IndividualChatBloc: Received chat update with ${updatedChat.messages.length} messages');
            print('🔍 IndividualChatBloc: Last message content: ${updatedChat.messages.isNotEmpty ? updatedChat.messages.last.content : "No messages"}');
            if (!isClosed && !emit.isDone) {
              emit(IndividualChatLoaded(updatedChat));
              print('🔍 IndividualChatBloc: Emitted IndividualChatLoaded state');
            }
          },
          onError: (error) {
            print('🔍 IndividualChatBloc: Stream error: $error');
          },
        );
      } else {
        emit(const IndividualChatError('Chat not found'));
      }
    } catch (e) {
      emit(IndividualChatError('Failed to load chat: ${e.toString()}'));
    }
  }

  Future<void> _onChatSendMessage(IndividualChatSendMessage event, Emitter<IndividualChatState> emit) async {
    try {
      if (_currentUserId == null) {
        if (!emit.isDone) {
          emit(const IndividualChatError('User not authenticated'));
        }
        return;
      }
      
      print('🔍 IndividualChatBloc: Sending message from user $_currentUserId to chat ${event.chatId}');
      print('🔍 IndividualChatBloc: Message content: ${event.content}');
      
      // Get the current chat state before sending
      final currentChat = _chatService.getChat(event.chatId);
      if (currentChat != null) {
        // Emit loading state to show immediate feedback
        emit(IndividualChatLoaded(currentChat));
      }
      
      await _chatService.sendMessage(
        chatId: event.chatId,
        senderId: _currentUserId!,
        content: event.content,
      );
      print('🔍 IndividualChatBloc: Message sent successfully');
      
      // Get the updated chat immediately after sending
      final updatedChat = _chatService.getChat(event.chatId);
      if (updatedChat != null && !emit.isDone) {
        emit(IndividualChatLoaded(updatedChat));
      }
      
    } catch (e) {
      if (!emit.isDone) {
        emit(IndividualChatError('Failed to send message: ${e.toString()}'));
      }
    }
  }

  Future<void> _onChatMarkAsRead(IndividualChatMarkAsRead event, Emitter<IndividualChatState> emit) async {
    try {
      if (_currentUserId == null) {
        return;
      }
      
      await _chatService.markMessagesAsRead(event.chatId, _currentUserId!);
      
      // The chat will be updated via the stream subscription
      // No need to emit here as the stream will handle it
    } catch (e) {
      // Don't emit error for read status updates
      print('Failed to mark messages as read: ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _chatService.leaveChat();
    return super.close();
  }
}
