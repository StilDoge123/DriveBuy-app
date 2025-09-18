import 'package:equatable/equatable.dart';

enum UserInfoStatus { initial, loading, success, failure }

class UserInfoState extends Equatable {
  final Map<String, dynamic>? user;
  final UserInfoStatus status;
  final String? errorMessage;

  const UserInfoState({
    this.user,
    this.status = UserInfoStatus.initial,
    this.errorMessage,
  });

  UserInfoState copyWith({
    Map<String, dynamic>? user,
    UserInfoStatus? status,
    String? errorMessage,
  }) {
    return UserInfoState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, status, errorMessage];
} 