import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:drivebuy/presentation/screens/user_saved_ads/bloc/user_saved_ads_event.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../marketplace/widgets/car_ad_card.dart';
import '../../../domain/models/car_ad.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/user_saved_ads_bloc.dart';

class UserSavedAdsPage extends StatefulWidget {
  const UserSavedAdsPage({super.key});

  @override
  State<UserSavedAdsPage> createState() => _UserSavedAdsPageState();
}

class _UserSavedAdsPageState extends State<UserSavedAdsPage> {
  late Future<List<CarAd>> _futureAds;

  @override
  void initState() {
    super.initState();
    _futureAds = locator<UserRepository>().getSavedAds();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserSavedAdsBloc(router: GoRouter.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Запазени обяви')),
        body: SafeArea(
          bottom: true,
          child: FutureBuilder<List<CarAd>>(
            future: _futureAds,
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Грешка при зареждане на запазени обяви:  ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Няма запазени обяви.'));
            }
            final ads = snapshot.data!;
            return ListView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) => CarAdCard(
                ad: ads[index],
                onTap: () {
                  context.read<UserSavedAdsBloc>().add(UserSavedAdsNavigateToAdDetails(ads[index].id));
                },
              ),
            );
            },
          ),
        ),
      ),
    );
  }
} 