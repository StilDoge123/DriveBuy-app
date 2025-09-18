import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String phone;
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.phone = '',
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? phone,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        name,
        phone,
        status,
        errorMessage,
      ];
} 