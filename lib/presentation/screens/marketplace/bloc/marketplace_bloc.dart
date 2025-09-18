import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/ad_repository.dart';
import '../../../../data/services/chat_service.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/chat_user.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final AdRepository _adRepository;
  final GoRouter _router;
  final ChatService _chatService;
  final UserRepository _userRepository;

  MarketplaceBloc({
    required AdRepository adRepository,
    required GoRouter router,
    required ChatService chatService,
    required UserRepository userRepository,
  }) : _adRepository = adRepository,
       _router = router,
       _chatService = chatService,
       _userRepository = userRepository,
       super(const MarketplaceState()) {
    on<MarketplaceLoadAds>(_onLoadAds);
    on<MarketplaceSearchAds>(_onSearchAds);
    on<MarketplaceUpdateFilter>(_onUpdateFilter);
    on<MarketplaceUpdateSort>(_onUpdateSort);
    on<MarketplaceNavigateToCreateAd>(_onNavigateToCreateAd);
    on<MarketplaceNavigateToProfile>(_onNavigateToProfile);
    on<MarketplaceNavigateToAdDetails>(_onNavigateToAdDetails);
    on<MarketplaceNavigateToRegister>(_onNavigateToRegister);
    on<MarketplaceNavigateToLogin>(_onNavigateToLogin);
    on<MarketplaceNavigateToUserListedAds>(_onNavigateToUserListedAds);
    on<MarketplaceNavigateToUserSavedAds>(_onNavigateToUserSavedAds);
    on<MarketplaceNavigateToChatList>(_onNavigateToChatList);
    on<MarketplaceNavigateToAIAssistant>(_onNavigateToAIAssistant);
    on<MarketplaceRefreshAds>(_onRefreshAds);
    on<MarketplaceStartChatForAd>(_onStartChatForAd);
  }

  Future<void> _onLoadAds(
    MarketplaceLoadAds event,
    Emitter<MarketplaceState> emit,
  ) async {
    print('🔍 MarketplaceBloc: Loading ads...');
    emit(state.copyWith(status: MarketplaceStatus.loading));
    try {
      // For marketplace listing, we don't need seller info - use lightweight endpoint
      final ads = await _adRepository.getAds();
      print('🔍 MarketplaceBloc: Loaded ${ads.length} ads');
      emit(state.copyWith(
        status: MarketplaceStatus.success,
        ads: ads,
      ));
    } catch (e) {
      print('🔍 MarketplaceBloc: Error loading ads: $e');
      emit(state.copyWith(
        status: MarketplaceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchAds(
    MarketplaceSearchAds event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(status: MarketplaceStatus.loading));
    try {
      final ads = await _adRepository.searchAds(state.filter);
      emit(state.copyWith(
        status: MarketplaceStatus.success,
        ads: ads,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarketplaceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateFilter(
    MarketplaceUpdateFilter event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onUpdateSort(
    MarketplaceUpdateSort event,
    Emitter<MarketplaceState> emit,
  ) {
    final updatedFilter = state.filter.copyWith(
      sortBy: event.sortBy,
    );
    
    emit(state.copyWith(filter: updatedFilter));
  }

  Future<void> _onNavigateToCreateAd(
    MarketplaceNavigateToCreateAd event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.createAd.name);
  }

  Future<void> _onNavigateToProfile(
    MarketplaceNavigateToProfile event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.userProfile.name);
  }

  Future<void> _onNavigateToAdDetails(
    MarketplaceNavigateToAdDetails event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.adDetails.name, pathParameters: {'id': event.adId.toString()});
    
    // Always refresh marketplace when returning from ad details 
    // since the user might have edited the ad
    await _onLoadAds(const MarketplaceLoadAds(), emit);
  }

  Future<void> _onNavigateToRegister(
    MarketplaceNavigateToRegister event, 
    Emitter<MarketplaceState> emit
    ) async {
    await _router.pushNamed(Routes.register.name);
  }

  Future<void> _onNavigateToLogin(
    MarketplaceNavigateToLogin event, 
    Emitter<MarketplaceState> emit
    ) async {
    await _router.pushNamed(Routes.login.name);
  }

  Future<void> _onNavigateToUserListedAds(
    MarketplaceNavigateToUserListedAds event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.userListedAds.name);
  }

  Future<void> _onNavigateToUserSavedAds(
    MarketplaceNavigateToUserSavedAds event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.userSavedAds.name);
  }

  Future<void> _onNavigateToChatList(
    MarketplaceNavigateToChatList event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.chatList.name);
  }

  Future<void> _onNavigateToAIAssistant(
    MarketplaceNavigateToAIAssistant event,
    Emitter<MarketplaceState> emit,
  ) async {
    await _router.pushNamed(Routes.aiAssistant.name);
  }

  Future<void> _onRefreshAds(
    MarketplaceRefreshAds event,
    Emitter<MarketplaceState> emit,
  ) async {
    print('🔍 MarketplaceBloc: _onRefreshAds called - refreshing ads...');
    // Refresh ads by directly calling the load logic
    await _onLoadAds(const MarketplaceLoadAds(), emit);
  }

  Future<void> _onStartChatForAd(
    MarketplaceStartChatForAd event,
    Emitter<MarketplaceState> emit,
  ) async {
    try {
      // Get current user
      final currentUserData = await _userRepository.getCurrentUser();
      final userId = currentUserData['id'] as String? ?? currentUserData['uid'] as String?;
      if (userId == null) {
        // Not logged in, route to login
        await _router.pushNamed(Routes.login.name);
        return;
      }

      // Prevent chatting with self
      if (userId == event.ad.userId) {
        return;
      }

      // Build chat users
      final buyer = ChatUser(
        id: userId,
        name: (currentUserData['name'] as String?) ?? (currentUserData['email'] as String?) ?? 'Unknown User',
        phone: currentUserData['phone'] as String?,
      );

      final sellerData = await _userRepository.getUser(event.ad.userId);
      final seller = ChatUser(
        id: event.ad.userId,
        name: (sellerData['name'] as String?) ?? (sellerData['email'] as String?) ?? 'Unknown User',
        phone: sellerData['phone'] as String?,
      );

      final chat = await _chatService.getOrCreateChat(
        adId: event.ad.id,
        adTitle: '${event.ad.make} ${event.ad.model} ${event.ad.title}',
        buyer: buyer,
        seller: seller,
      );

      await _router.pushNamed(
        Routes.chat.name,
        pathParameters: {'chatId': chat.id.toString()},
        extra: {
          'adId': event.ad.id,
          'adTitle': '${event.ad.make} ${event.ad.model} ${event.ad.title}',
          'otherUser': seller,
          'currentUserId': userId,
        },
      );
    } catch (e) {
      // Swallow to avoid breaking UI; errors can be surfaced via UI cubit/snackbar elsewhere
      print('🔍 MarketplaceBloc: Failed to start chat: $e');
    }
  }
} 