import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:drivebuy/presentation/screens/user_listed_ads/bloc/user_listed_ads_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
class UserListedAdsBloc extends Bloc<UserListedAdsNavigateToAdDetails, void> {
  final GoRouter _router;
  UserListedAdsBloc({required GoRouter router}) : _router = router, super(null) {
    on<UserListedAdsNavigateToAdDetails>((event, emit) async {
      await _router.pushNamed(Routes.adDetails.name, pathParameters: {'id': event.adId.toString()});
    });
  }
} 