import 'package:equatable/equatable.dart';
import '../../../../domain/models/car_ad.dart';
import '../../../../domain/models/car_search_filter.dart';

enum MarketplaceStatus { initial, loading, success, failure }

class MarketplaceState extends Equatable {
  final List<CarAd> ads;
  final CarSearchFilter filter;
  final MarketplaceStatus status;
  final String? errorMessage;

  const MarketplaceState({
    this.ads = const [],
    this.filter = const CarSearchFilter(),
    this.status = MarketplaceStatus.initial,
    this.errorMessage,
  });

  MarketplaceState copyWith({
    List<CarAd>? ads,
    CarSearchFilter? filter,
    MarketplaceStatus? status,
    String? errorMessage,
  }) {
    return MarketplaceState(
      ads: ads ?? this.ads,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [ads, filter, status, errorMessage];
} 