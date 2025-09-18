import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/ad_repository.dart';
import '../../../app/router/router/routes.dart';
import 'seller_ads_event.dart';
import 'seller_ads_state.dart';

class SellerAdsBloc extends Bloc<SellerAdsEvent, SellerAdsState> {
  final AdRepository adRepository;
  final GoRouter _router;

  SellerAdsBloc({
    required this.adRepository,
    required GoRouter router,
  }) : _router = router,
    super(const SellerAdsInitial()) {
    on<SellerAdsLoad>(_onLoad);
    on<SellerAdsNavigateToAdDetails>(_onNavigateToAdDetails);
  }

  Future<void> _onLoad(SellerAdsLoad event, Emitter<SellerAdsState> emit) async {
    emit(const SellerAdsLoading());
    
    try {
      final ads = await adRepository.getAdsByUserId(event.sellerId);
      emit(SellerAdsLoaded(ads));
    } catch (e) {
      emit(SellerAdsError(e.toString()));
    }
  }

  void _onNavigateToAdDetails(SellerAdsNavigateToAdDetails event, Emitter<SellerAdsState> emit) {
    _router.pushNamed(Routes.adDetails.name, pathParameters: {'id': event.adId.toString()});
  }
}
