import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/user_repository.dart';
import 'user_info_event.dart';
import 'user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final UserRepository _userRepository;
  final GoRouter _router;
  final AuthRepository _authRepository;

  UserInfoBloc({
    required UserRepository userRepository,
    required GoRouter router,
    required AuthRepository authRepository,
    }) : _userRepository = userRepository,
         _router = router,
         _authRepository = authRepository,
         super(const UserInfoState()) {
    on<UserInfoLoaded>(_onUserInfoLoaded);
    on<NavigateToMarketplace>(_onNavigateToMarketplace);
    on<NavigateToUserListedAds>(_onNavigateToUserListedAds);
    on<NavigateToUserSavedAds>(_onNavigateToUserSavedAds);
    on<NavigateToEditUser>(_onNavigateToEditUser);
    on<GoToMarketplace>(_onGoToMarketplace);
  }

  Future<void> _onUserInfoLoaded(
    UserInfoLoaded event,
    Emitter<UserInfoState> emit,
  ) async {
    emit(state.copyWith(status: UserInfoStatus.loading));
    try {
      final user = await _userRepository.getCurrentUser();
      emit(state.copyWith(
        status: UserInfoStatus.success,
        user: user,
      ));
    } catch (e) {
      if (e.toString().contains('User account not found in backend')) {
        await _authRepository.signOut();
        _router.goNamed(Routes.login.name);
      } else {
        emit(state.copyWith(
          status: UserInfoStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onNavigateToMarketplace(
    NavigateToMarketplace event, 
    Emitter<UserInfoState> emit
    ) async {
    await _router.pushNamed(Routes.marketplace.name);
  }

  void _onGoToMarketplace(
    GoToMarketplace event, 
    Emitter<UserInfoState> emit
    ) {
    _router.goNamed(Routes.marketplace.name);
  }

  Future<void> _onNavigateToUserListedAds(
    NavigateToUserListedAds event,
    Emitter<UserInfoState> emit,
  ) async {
    await _router.pushNamed(Routes.userListedAds.name);
  }

  Future<void> _onNavigateToUserSavedAds(
    NavigateToUserSavedAds event,
    Emitter<UserInfoState> emit,
  ) async {
    await _router.pushNamed(Routes.userSavedAds.name);
  }

  Future<void> _onNavigateToEditUser(
    NavigateToEditUser event,
    Emitter<UserInfoState> emit,
  ) async {
    await _router.pushNamed(Routes.editUser.name);
  }
} 