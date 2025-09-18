abstract class SellerAdsEvent {}

class SellerAdsLoad extends SellerAdsEvent {
  final String sellerId;

  SellerAdsLoad(this.sellerId);
}

class SellerAdsNavigateToAdDetails extends SellerAdsEvent {
  final int adId;

  SellerAdsNavigateToAdDetails(this.adId);
}
