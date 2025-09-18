import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final AuthRepository _authRepository;
  final GoRouter _router;

  LoginBloc({
    required AuthRepository authRepository,
    required GoRouter router,
    })
      : _authRepository = authRepository,
        _router = router,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<NavigateToRegister>(_onNavigateToRegister);
    on<NavigateToMarketplace>(_onNavigateToMarketplace);
  }

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onNavigateToRegister(
    NavigateToRegister event, 
    Emitter<LoginState> emit
    ) async {
    await _router.pushNamed(Routes.register.name);
  }

  Future<void> _onNavigateToMarketplace(
    NavigateToMarketplace event, 
    Emitter<LoginState> emit
    ) async {
    await _router.pushNamed(Routes.marketplace.name);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please fill in all fields',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.code == 'invalid-credential'
            ? 'Invalid email or password.'
            : 'An unknown error occurred. Please try again.',
      ));
    } on PlatformException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.code == 'invalid-credential'
            ? 'Invalid email or password.'
            : e.message ?? 'A platform error occurred. Please try again.',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'An unknown error occurred. Please try again.',
      ));
    }
  }
} 