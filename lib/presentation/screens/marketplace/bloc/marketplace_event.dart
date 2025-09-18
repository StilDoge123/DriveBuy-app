import 'package:equatable/equatable.dart';
import '../../../../domain/models/car_ad.dart';
import '../../../../domain/models/car_search_filter.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class MarketplaceLoadAds extends MarketplaceEvent {
  const MarketplaceLoadAds();
}

class MarketplaceUpdateFilter extends MarketplaceEvent {
  final CarSearchFilter filter;

  const MarketplaceUpdateFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class MarketplaceSearchAds extends MarketplaceEvent {
  const MarketplaceSearchAds();
}

class MarketplaceUpdateSort extends MarketplaceEvent {
  final String? sortBy;

  const MarketplaceUpdateSort({
    required this.sortBy,
  });

  @override
  List<Object?> get props => [sortBy];
}

class MarketplaceNavigateToCreateAd extends MarketplaceEvent {
  const MarketplaceNavigateToCreateAd();
}

class MarketplaceNavigateToProfile extends MarketplaceEvent {
  const MarketplaceNavigateToProfile();
}

class MarketplaceNavigateToAdDetails extends MarketplaceEvent {
  final int adId;

  const MarketplaceNavigateToAdDetails(this.adId);

  @override
  List<Object?> get props => [adId];
}

class MarketplaceNavigateToRegister extends MarketplaceEvent {
  const MarketplaceNavigateToRegister();
}

class MarketplaceNavigateToLogin extends MarketplaceEvent {
  const MarketplaceNavigateToLogin();
}

class MarketplaceNavigateToUserListedAds extends MarketplaceEvent {
  const MarketplaceNavigateToUserListedAds();
}

class MarketplaceNavigateToUserSavedAds extends MarketplaceEvent {
  const MarketplaceNavigateToUserSavedAds();
} 

class MarketplaceNavigateToChatList extends MarketplaceEvent {
  const MarketplaceNavigateToChatList();
}

class MarketplaceNavigateToAIAssistant extends MarketplaceEvent {
  const MarketplaceNavigateToAIAssistant();
}

class MarketplaceRefreshAds extends MarketplaceEvent {
  const MarketplaceRefreshAds();
}

class MarketplaceStartChatForAd extends MarketplaceEvent {
  final CarAd ad;

  const MarketplaceStartChatForAd(this.ad);

  @override
  List<Object?> get props => [ad];
}