import '../../../../domain/models/car_ad.dart';

abstract class SellerAdsState {
  const SellerAdsState();
}

class SellerAdsInitial extends SellerAdsState {
  const SellerAdsInitial();
}

class SellerAdsLoading extends SellerAdsState {
  const SellerAdsLoading();
}

class SellerAdsLoaded extends SellerAdsState {
  final List<CarAd> ads;

  const SellerAdsLoaded(this.ads);
}

class SellerAdsError extends SellerAdsState {
  final String message;

  const SellerAdsError(this.message);
}
