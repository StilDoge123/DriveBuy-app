import 'package:equatable/equatable.dart';

abstract class AdDetailsEvent extends Equatable {
  const AdDetailsEvent();

  @override
  List<Object?> get props => [];
}

class AdDetailsLoad extends AdDetailsEvent {
  final int adId;

  const AdDetailsLoad(this.adId);

  @override
  List<Object?> get props => [adId];
}

class AdDetailsCallOwner extends AdDetailsEvent {
  final String phoneNumber;

  const AdDetailsCallOwner(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AdDetailsNavigateToProfile extends AdDetailsEvent {
  final String userId;

  const AdDetailsNavigateToProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AdDetailsNavigateToSellerAds extends AdDetailsEvent {
  final String sellerId;
  final String sellerName;

  const AdDetailsNavigateToSellerAds(this.sellerId, this.sellerName);

  @override
  List<Object?> get props => [sellerId, sellerName];
}

class AdDetailsNavigateToEdit extends AdDetailsEvent {
  final int adId;

  const AdDetailsNavigateToEdit(this.adId);

  @override
  List<Object?> get props => [adId];
}

class AdDetailsDelete extends AdDetailsEvent {
  final int adId;

  const AdDetailsDelete(this.adId);

  @override
  List<Object?> get props => [adId];
} 