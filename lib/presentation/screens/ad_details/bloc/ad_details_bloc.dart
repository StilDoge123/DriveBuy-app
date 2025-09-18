import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/repositories/ad_repository.dart';
import '../../../app/router/router/routes.dart';
import 'ad_details_event.dart';
import 'ad_details_state.dart';

class AdDetailsBloc extends Bloc<AdDetailsEvent, AdDetailsState> {
  final AdRepository _adRepository;
  final GoRouter _router;

  AdDetailsBloc({
    required AdRepository adRepository,
    required GoRouter router,
  })  : _adRepository = adRepository,
        _router = router,
        super(AdDetailsInitial()) {
    on<AdDetailsLoad>(_onLoad);
    on<AdDetailsCallOwner>(_onCallOwner);
    on<AdDetailsNavigateToProfile>(_onNavigateToProfile);
    on<AdDetailsNavigateToSellerAds>(_onNavigateToSellerAds);
    on<AdDetailsNavigateToEdit>(_onNavigateToEdit);
    on<AdDetailsDelete>(_onDelete);
  }

  Future<void> _onLoad(AdDetailsLoad event, Emitter<AdDetailsState> emit) async {
    emit(AdDetailsLoading());
    try {
      // Use the new method that includes seller info to reduce API calls
      final adWithSeller = await _adRepository.getAdWithSeller(event.adId);
      emit(AdDetailsLoaded(adWithSeller));
    } catch (e) {
      emit(AdDetailsError(e.toString()));
    }
  }

  Future<void> _onCallOwner(AdDetailsCallOwner event, Emitter<AdDetailsState> emit) async {
    final uri = Uri.parse('tel:${event.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _onNavigateToProfile(AdDetailsNavigateToProfile event, Emitter<AdDetailsState> emit) async{
    _router.pushNamed(Routes.userProfile.name);
  }

  Future<void> _onNavigateToSellerAds(AdDetailsNavigateToSellerAds event, Emitter<AdDetailsState> emit) async {
    _router.pushNamed(Routes.sellerAds.name, pathParameters: {'sellerId': event.sellerId}, 
    extra: {
      'sellerName': event.sellerName,
      });
  }

  Future<void> _onNavigateToEdit(AdDetailsNavigateToEdit event, Emitter<AdDetailsState> emit) async {
    final result = await _router.pushNamed(
      Routes.editAd.name, 
      pathParameters: {'id': event.adId.toString()},
    );
    
    // If the edit was successful (result == true), reload the ad details
    if (result == true) {
      add(AdDetailsLoad(event.adId));
    }
  }

  Future<void> _onDelete(AdDetailsDelete event, Emitter<AdDetailsState> emit) async {
    try {
      emit(AdDetailsLoading());
      await _adRepository.deleteAd(event.adId);
      // Navigate back after successful deletion
      _router.pop();
    } catch (e) {
      emit(AdDetailsError('Failed to delete ad: ${e.toString()}'));
    }
  }
} 