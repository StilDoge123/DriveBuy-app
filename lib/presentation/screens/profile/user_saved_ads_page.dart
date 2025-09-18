import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drivebuy/presentation/app/bloc/saved_ads_cubit.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';

class UserSavedAdsPage extends StatefulWidget {
  const UserSavedAdsPage({super.key});

  @override
  State<UserSavedAdsPage> createState() => _UserSavedAdsPageState();
}

class _UserSavedAdsPageState extends State<UserSavedAdsPage> {
  @override
  Widget build(BuildContext context) {
    return _UserSavedAdsBody();
  }
}

class _UserSavedAdsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state;
    final userId = user?.uid;
    if (userId != null) {
      context.read<SavedAdsCubit>().fetchSavedAds(userId);
    }
    return BlocBuilder<SavedAdsCubit, Set<int>>(
      builder: (context, savedAds) {
        if (userId == null) {
          return const Center(child: Text('Влезте или се регистрирайте, за да запазите обява.'));
        }
        if (savedAds.isEmpty) {
          return const Center(child: Text('Няма запазени обяви.'));
        }
        return ListView(
          children: savedAds.map((adId) => ListTile(
            title: Text('Ad ID: $adId'),
          )).toList(),
        );
      },
    );
  }
} 