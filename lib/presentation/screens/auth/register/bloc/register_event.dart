import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  const RegisterEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  const RegisterPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class RegisterConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;

  const RegisterConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class RegisterNameChanged extends RegisterEvent {
  final String name;

  const RegisterNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class RegisterPhoneChanged extends RegisterEvent {
  final String phone;

  const RegisterPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class NavigateToMarketplace extends RegisterEvent {
  const NavigateToMarketplace();
}

class NavigateToLogin extends RegisterEvent {
  const NavigateToLogin();
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
} 
