import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/services/chat_service.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/chat.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatService _chatService;
  StreamSubscription<List<Chat>>? _chatsListSubscription;
  String? _currentUserId;
  bool _hasLoadedChats = false;

  ChatListBloc({
    required ChatService chatService,
    required UserRepository userRepository,
  })  : _chatService = chatService,
        super(const ChatListInitial()) {
    on<ChatListLoad>(_onChatListLoad);
    on<ChatListRefresh>(_onChatListRefresh);
    on<ChatListCacheUpdate>(_onChatListCacheUpdate);
    on<ChatListUserChanged>(_onChatListUserChanged);
  }

  void _onChatListUserChanged(ChatListUserChanged event, Emitter<ChatListState> emit) {
    final newUserId = event.userId;
    print('🔍 ChatListBloc: User changed from $_currentUserId to $newUserId');
    
    // If user changed, reset loaded state
    if (_currentUserId != newUserId) {
      _hasLoadedChats = false;
      _currentUserId = newUserId;
      
      // If user is null (logged out), emit initial state
      if (newUserId == null) {
        emit(const ChatListInitial());
      }
    }
  }

  Future<void> _onChatListLoad(ChatListLoad event, Emitter<ChatListState> emit) async {
    // Get current user ID from Firebase Auth
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _currentUserId = firebaseUser?.uid;
    
    if (_currentUserId == null) {
      emit(const ChatListError('User not authenticated'));
      return;
    }

    final currentUserId = _currentUserId!; // Safe to use after null check

    // If we already have chats loaded, just use the cache
    if (_hasLoadedChats) {
      print('🔍 ChatListBloc: Using cached chats for user $currentUserId');
      final userChats = _chatService.getUserChats(currentUserId);
      emit(ChatListLoaded(userChats, isRefreshing: false));
      return;
    }

    emit(const ChatListLoading());
    print('🔍 ChatListBloc: Loading chats from backend for user $currentUserId');

    try {
      // Connect to realtime notifications (non-critical)
      try {
        await _chatService.connectUserRealtime(currentUserId);
      } catch (e) {
        print('🔍 ChatListBloc: Failed to connect realtime (non-critical): $e');
        // Continue without realtime - not critical for basic functionality
      }
      
      // Load chats from backend
      await _chatService.loadUserChats();
      _hasLoadedChats = true;
      
      // Listen for chat list updates (cache-only; do NOT trigger network)
      _chatsListSubscription?.cancel();
      _chatsListSubscription = _chatService.chatsStream.listen((chats) {
        print('🔍 ChatListBloc: Received chats stream update with ${chats.length} chats');
        print('🔍 ChatListBloc: Current state: $state');
        print('🔍 ChatListBloc: isClosed: $isClosed');
        if (!isClosed) {
          print('🔍 ChatListBloc: Triggering ChatListCacheUpdate due to stream update');
          add(const ChatListCacheUpdate());
        } else {
          print('🔍 ChatListBloc: Bloc is closed, not processing update');
        }
      });
      
      // Get initial chats
      final userChats = _chatService.getUserChats(currentUserId);
      emit(ChatListLoaded(userChats, isRefreshing: false));
      
    } catch (e) {
      emit(ChatListError('Failed to load chats: ${e.toString()}'));
    }
  }

  Future<void> _onChatListRefresh(ChatListRefresh event, Emitter<ChatListState> emit) async {
    print('🔍 ChatListBloc: _onChatListRefresh called');
    if (_currentUserId == null) return;
    
    final currentUserId = _currentUserId!; // Safe to use after null check
    
    // Get current chats to show while refreshing
    final currentChats = _chatService.getUserChats(currentUserId);
    
    // Emit loading state with current chats
    emit(ChatListLoaded(currentChats, isRefreshing: true));
    
    try {
      print('🔍 ChatListBloc: Loading user chats from backend...');
      // Reload chats from backend for a fresh update
      await _chatService.loadUserChats();
      _hasLoadedChats = true; // Mark as loaded after refresh
      
      final userChats = _chatService.getUserChats(currentUserId);
      print('🔍 ChatListBloc: Loaded ${userChats.length} chats, emitting ChatListLoaded');
      emit(ChatListLoaded(userChats, isRefreshing: false));
    } catch (e) {
      // Don't emit error state on refresh failure, just keep current state
      print('🔍 ChatListBloc: Refresh failed: $e');
      final userChats = _chatService.getUserChats(currentUserId);
      emit(ChatListLoaded(userChats, isRefreshing: false));
    }
  }

  Future<void> _onChatListCacheUpdate(ChatListCacheUpdate event, Emitter<ChatListState> emit) async {
    print('🔍 ChatListBloc: _onChatListCacheUpdate called');
    
    // Double-check authentication state during cache updates
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentAuthUserId = firebaseUser?.uid;
    
    if (currentAuthUserId == null) {
      print('🔍 ChatListBloc: User not authenticated during cache update, skipping');
      return;
    }
    
    // Update our stored user ID if it has changed
    if (_currentUserId != currentAuthUserId) {
      print('🔍 ChatListBloc: User ID changed from $_currentUserId to $currentAuthUserId during cache update');
      _currentUserId = currentAuthUserId;
    }
    
    final userChats = _chatService.getUserChats(currentAuthUserId);
    print('🔍 ChatListBloc: Got ${userChats.length} user chats');
    print('🔍 ChatListBloc: emit.isDone: ${emit.isDone}');
    
    if (!emit.isDone && !isClosed) {
      print('🔍 ChatListBloc: Emitting ChatListLoaded with ${userChats.length} chats');
      emit(ChatListLoaded(userChats, isRefreshing: false));
    } else {
      print('🔍 ChatListBloc: Emitter is done or bloc is closed, not emitting');
    }
  }

  /// Get total unread message count across all chats for the current user
  int getTotalUnreadCount() {
    if (_currentUserId == null) return 0;
    
    final currentUserId = _currentUserId!; // Safe to use after null check
    final userChats = _chatService.getUserChats(currentUserId);
    final totalUnread = userChats.fold(0, (total, chat) => total + chat.getUnreadCount(currentUserId));
    print('🔍 ChatListBloc: getTotalUnreadCount - userChats: ${userChats.length}, totalUnread: $totalUnread');
    for (final chat in userChats) {
      final unreadCount = chat.getUnreadCount(currentUserId);
      if (unreadCount > 0) {
        print('🔍 ChatListBloc: Chat ${chat.id} has $unreadCount unread messages');
      }
    }
    return totalUnread;
  }

  /// Reset the loaded state (useful when user logs out)
  void resetLoadedState() {
    _hasLoadedChats = false;
    _currentUserId = null;
    print('🔍 ChatListBloc: Reset loaded state');
  }

  @override
  Future<void> close() {
    _chatsListSubscription?.cancel();
    return super.close();
  }
}
