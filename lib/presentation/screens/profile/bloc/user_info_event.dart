import 'package:equatable/equatable.dart';

abstract class UserInfoEvent extends Equatable {
  const UserInfoEvent();

  @override
  List<Object?> get props => [];
}

class UserInfoLoaded extends UserInfoEvent {
  const UserInfoLoaded();

  @override
  List<Object?> get props => [];
} 

class NavigateToMarketplace extends UserInfoEvent {
  const NavigateToMarketplace();
} 

class GoToMarketplace extends UserInfoEvent {
  const GoToMarketplace();
}

class NavigateToUserListedAds extends UserInfoEvent {
  const NavigateToUserListedAds();
}

class NavigateToUserSavedAds extends UserInfoEvent {
  const NavigateToUserSavedAds();
} 

class NavigateToEditUser extends UserInfoEvent {
  const NavigateToEditUser();
} 