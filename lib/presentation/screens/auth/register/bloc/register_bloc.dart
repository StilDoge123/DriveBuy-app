import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  
final AuthRepository _authRepository;
  final GoRouter _router;

  RegisterBloc({
    required AuthRepository authRepository,
    required GoRouter router,

  }) : _authRepository = authRepository,
       _router = router,
       super(const RegisterState()) {
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterNameChanged>(_onNameChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<NavigateToMarketplace>(_onNavigateToMarketplace);
    on<NavigateToLogin>(_onNavigateToLogin);
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword));
  }

  void _onNameChanged(
    RegisterNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    if (!_validateFields(emit)) {
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await _authRepository.register(
        name: state.name,
        email: state.email,
        password: state.password,
        phone: state.phone,
      );
      emit(state.copyWith(status: RegisterStatus.success));
      _router.pop();
    } catch (error) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  bool _validateFields(Emitter<RegisterState> emit) {
    if (state.email.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty ||
        state.name.isEmpty ||
        state.phone.isEmpty) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Please fill in all fields',
      ));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.email)) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Please enter a valid email address',
      ));
      return false;
    }

    if (state.password.length < 6) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Password must be at least 6 characters long',
      ));
      return false;
    }

    if (state.password != state.confirmPassword) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Passwords do not match',
      ));
      return false;
    }

    return true;
  }

  Future<void> _onNavigateToMarketplace(
    NavigateToMarketplace event, 
    Emitter<RegisterState> emit
    ) async {
    await _router.pushNamed(Routes.marketplace.name);
  }

  Future<void> _onNavigateToLogin(
    NavigateToLogin event, 
    Emitter<RegisterState> emit
    ) async {
    await _router.pushNamed(Routes.login.name);
  }
} 