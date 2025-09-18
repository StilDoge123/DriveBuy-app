import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:drivebuy/presentation/screens/user_listed_ads/bloc/user_listed_ads_event.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../marketplace/widgets/car_ad_card.dart';
import '../../../domain/models/car_ad.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/user_listed_ads_bloc.dart';

class UserListedAdsPage extends StatefulWidget {
  const UserListedAdsPage({super.key});

  @override
  State<UserListedAdsPage> createState() => _UserListedAdsPageState();
}

class _UserListedAdsPageState extends State<UserListedAdsPage> {
  late Future<List<CarAd>> _futureAds;

  @override
  void initState() {
    super.initState();
    _futureAds = locator<UserRepository>().getListedAds();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserListedAdsBloc(router: GoRouter.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Моите обяви')),
        body: SafeArea(
          bottom: true,
          child: FutureBuilder<List<CarAd>>(
            future: _futureAds,
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Неуспешно зреждане на обяви:  ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Все още няма обяви.'));
            }
            final ads = snapshot.data!;
            return ListView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) => CarAdCard(
                ad: ads[index],
                onTap: () {
                  context.read<UserListedAdsBloc>().add(UserListedAdsNavigateToAdDetails(ads[index].id));
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