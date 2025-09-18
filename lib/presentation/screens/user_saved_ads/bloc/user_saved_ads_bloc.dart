import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:drivebuy/presentation/screens/user_saved_ads/bloc/user_saved_ads_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserSavedAdsBloc extends Bloc<UserSavedAdsNavigateToAdDetails, void> {
  final GoRouter _router;
  UserSavedAdsBloc({required GoRouter router}) : _router = router, super(null) {
    on<UserSavedAdsNavigateToAdDetails>((event, emit) async {
      await _router.pushNamed(Routes.adDetails.name, pathParameters: {'id': event.adId.toString()});
    });
  }
} 