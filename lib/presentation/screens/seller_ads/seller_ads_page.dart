import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/ad_repository.dart';
import '../marketplace/widgets/car_ad_card.dart';
import 'bloc/seller_ads_bloc.dart';
import 'bloc/seller_ads_event.dart';
import 'bloc/seller_ads_state.dart';

class SellerAdsPage extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const SellerAdsPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerAdsBloc(
        adRepository: AdRepository(),
        router: GoRouter.of(context),
      )..add(SellerAdsLoad(sellerId)),
      child: SellerAdsView(sellerId: sellerId, sellerName: sellerName),
    );
  }
}

class SellerAdsView extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const SellerAdsView({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Обяви от $sellerName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SellerAdsBloc, SellerAdsState>(
        builder: (context, state) {
          if (state is SellerAdsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SellerAdsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SellerAdsBloc>().add(SellerAdsLoad(sellerId));
                    },
                    child: const Text('Опитай отново'),
                  ),
                ],
              ),
            );
          }

          if (state is SellerAdsLoaded) {
            if (state.ads.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Няма намерени обяви от този продавач.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.ads.length,
              itemBuilder: (context, index) {
                final ad = state.ads[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CarAdCard(
                    ad: ad,
                    onTap: () {
                      context.read<SellerAdsBloc>().add(
                        SellerAdsNavigateToAdDetails(ad.id),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
