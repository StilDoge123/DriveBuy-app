import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../domain/models/car_ad.dart';
import '../../../../config/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/bloc/auth_cubit.dart';
import '../../../app/bloc/saved_ads_cubit.dart';
import '../../../app/di/locator.dart';
import '../../marketplace/bloc/marketplace_bloc.dart';
import '../../marketplace/bloc/marketplace_event.dart';

class CarAdCard extends StatefulWidget {
  final CarAd ad;
  final VoidCallback? onTap;

  const CarAdCard({
    super.key,
    required this.ad,
    this.onTap,
  });

  @override
  State<CarAdCard> createState() => _CarAdCardState();
}

class _CarAdCardState extends State<CarAdCard> {
  bool _isStartingChat = false;

  Future<void> _toggleSave(BuildContext context) async {
    final user = context.read<AuthCubit>().state;
    final userId = user?.uid;
    final baseUrl = ApiConfig.baseUrl;
    final savedAdsCubit = context.read<SavedAdsCubit>();
    final isSaved = savedAdsCubit.isAdSaved(widget.ad.id);
    final dio = locator<Dio>();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Влезте или се регистрирайте, за да запазите обява.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    try {
      if (isSaved) {
        final url = '$baseUrl/users/$userId/saved-ads/remove/${widget.ad.id}';
        await dio.post(url);
        savedAdsCubit.removeSavedAd(widget.ad.id);
      } else {
        final url = '$baseUrl/users/$userId/saved-ads/${widget.ad.id}';
        await dio.post(url);
        savedAdsCubit.addSavedAd(widget.ad.id);
      }
    } catch (e) {
      print('Error saving/unsaving ad: $e');
    }
  }

  Future<void> _startChat(BuildContext context) async {
    if (_isStartingChat) return;

    setState(() {
      _isStartingChat = true;
    });

    // Delegate logic to MarketplaceBloc to avoid using context after awaits
    context.read<MarketplaceBloc>().add(MarketplaceStartChatForAd(widget.ad));

    if (mounted) {
      setState(() {
        _isStartingChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedAdsCubit, Set<int>>(
      builder: (context, savedAds) {
        final isSaved = savedAds.contains(widget.ad.id);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.ad.imageUrls.isNotEmpty)
                  Stack(
                    children: [
                      Image.network(
                        widget.ad.imageUrls.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error_outline),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: _isStartingChat 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.chat, color: Colors.white),
                              onPressed: _isStartingChat ? null : () => _startChat(context),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () => _toggleSave(context),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.ad.make} ${widget.ad.model} ${widget.ad.title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.ad.price.toString()}€',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.ad.year}г. 🚗 ${widget.ad.mileage}км 🚗 ${widget.ad.horsepower}к.с. 🚗 ${widget.ad.fuelType}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Намира се в:  ${widget.ad.region ?? ''}${widget.ad.city != null ? (widget.ad.region != null ? ', ' : '') + widget.ad.city! : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 