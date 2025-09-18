import 'dart:async';

import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<User?> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(null) {
    _userSubscription = _authRepository.user.listen((user) {
      emit(user);
    });
  }

  void setRegistered(bool value) {}

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
} 