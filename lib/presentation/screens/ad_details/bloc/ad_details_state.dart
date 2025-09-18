import 'package:equatable/equatable.dart';
import '../../../../domain/models/car_ad_with_seller.dart';

abstract class AdDetailsState extends Equatable {
  const AdDetailsState();

  @override
  List<Object?> get props => [];
}

class AdDetailsInitial extends AdDetailsState {}

class AdDetailsLoading extends AdDetailsState {}

class AdDetailsLoaded extends AdDetailsState {
  final CarAdWithSeller ad;

  const AdDetailsLoaded(this.ad);

  @override
  List<Object?> get props => [ad];
}

class AdDetailsError extends AdDetailsState {
  final String message;

  const AdDetailsError(this.message);

  @override
  List<Object?> get props => [message];
} 