import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/ad_repository.dart';
import 'bloc/ad_details_bloc.dart';
import 'bloc/ad_details_event.dart';
import 'bloc/ad_details_state.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';
import 'package:dio/dio.dart';
import '../../../config/api_config.dart';
import 'package:drivebuy/presentation/app/bloc/saved_ads_cubit.dart';
import '../../app/di/locator.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/chat_user.dart';
import '../../widgets/photo_gallery_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsPage extends StatelessWidget {
  final int adId;

  const AdDetailsPage({
    super.key,
    required this.adId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdDetailsBloc(
        adRepository: AdRepository(),
        router: GoRouter.of(context),
      )..add(AdDetailsLoad(adId)),
      child: AdDetailsView(adId: adId),
    );
  }
}

class AdDetailsView extends StatefulWidget {
  final int adId;
  const AdDetailsView({super.key, required this.adId});

  @override
  State<AdDetailsView> createState() => _AdDetailsViewState();
}

class _AdDetailsViewState extends State<AdDetailsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _fetchedSavedAds = false;

  Future<void> _toggleSave(BuildContext context, int adId) async {
    final user = context.read<AuthCubit>().state;
    final userId = user?.uid;
    final baseUrl = ApiConfig.baseUrl;
    final savedAdsCubit = context.read<SavedAdsCubit>();
    final isSaved = savedAdsCubit.isAdSaved(adId);
    final dio = locator<Dio>();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in or register to save ads.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    try {
      if (isSaved) {
        final url = '$baseUrl/users/$userId/saved-ads/remove/$adId';
        await dio.post(url);
        savedAdsCubit.removeSavedAd(adId);
      } else {
        final url = '$baseUrl/users/$userId/saved-ads/$adId';
        await dio.post(url);
        savedAdsCubit.addSavedAd(adId);
      }
    } catch (e) {
      print('Error saving/unsaving ad: $e');
    }
  }

  Future<void> _startChat(BuildContext context, int adId, String adTitle, String sellerId, String sellerName, String sellerPhone) async {
    final user = context.read<AuthCubit>().state;
    final userId = user?.uid;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Влезте или се регистрирайте, за да започнете чат.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (userId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не можете да започнете чат със себе си.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final chatService = locator<ChatService>();
      final userRepository = locator<UserRepository>();
      
      // Get current user info
      final currentUserData = await userRepository.getCurrentUser();
      
      final buyer = ChatUser(
        id: userId,
        name: currentUserData['name'] ?? currentUserData['email'] ?? 'Unknown User',
        phone: currentUserData['phone'],
      );
      
      // Use seller info from the passed parameters
      final seller = ChatUser(
        id: sellerId,
        name: sellerName,
        phone: sellerPhone,
      );
      
      final chat = await chatService.getOrCreateChat(
        adId: adId,
        adTitle: adTitle,
        buyer: buyer,
        seller: seller,
      );
      
      if (context.mounted) {
        context.push('/chat/${chat.id}', extra: {
          'adId': adId,
          'adTitle': adTitle,
          'otherUser': seller,
          'currentUserId': userId,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPhotoGallery(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PhotoGalleryOverlay(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
            adId: widget.adId,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String _getTechnicalDataUrl(String make) {
    return 'https://www.autodata1.com/bg/car/${make.toLowerCase()}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, int adId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Потвърждение'),
          content: const Text('Сигурни ли сте, че искате да изтриете тази обява? Това действие не може да бъде отменено.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отказ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AdDetailsBloc>().add(AdDetailsDelete(adId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Изтрий'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DriveBuy'),
        actions: [
          BlocBuilder<SavedAdsCubit, Set<int>>(
            builder: (context, savedAds) {
              final user = context.watch<AuthCubit>().state;
              final userId = user?.uid;
              final state = context.read<AdDetailsBloc>().state;
              int? adId;
              if (state is AdDetailsLoaded) {
                adId = state.ad.id;
              } else {
                adId = widget.adId;
              }
              if (!_fetchedSavedAds && userId != null) {
                _fetchedSavedAds = true;
                context.read<SavedAdsCubit>().fetchSavedAds(userId);
              }
              final isSaved = savedAds.contains(adId);
              return IconButton(
                icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                color: Colors.red,
                onPressed: () => _toggleSave(context, adId!),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdDetailsBloc, AdDetailsState>(
        builder: (context, state) {
          if (state is AdDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdDetailsBloc>().add(AdDetailsLoad(widget.adId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdDetailsLoaded) {
            final ad = state.ad;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery with arrows and index
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: ad.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showPhotoGallery(context, ad.imageUrls, index),
                              child: Hero(
                                tag: 'photo_${ad.id}_$index',
                                child: Image.network(
                                  ad.imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          },
                        ),
                        if (ad.imageUrls.length > 1) ...[
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                              onPressed: _currentPage > 0
                                  ? () {
                                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    }
                                  : null,
                              splashRadius: 24,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                              onPressed: _currentPage < ad.imageUrls.length - 1
                                  ? () {
                                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    }
                                  : null,
                              splashRadius: 24,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ],
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${_currentPage + 1}/${ad.imageUrls.length}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title and Price
                  Text(
                    '${ad.make} ${ad.model}${ad.title != null && ad.title!.isNotEmpty ? ' ${ad.title}' : ''}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ad.price} €',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Owner controls (Edit/Delete) - only show if current user is the owner
                  BlocBuilder<AuthCubit, dynamic>(
                    builder: (context, authState) {
                      final currentUserId = authState?.uid;
                      final isOwner = currentUserId != null && currentUserId == ad.seller.id;
                      
                      if (!isOwner) return const SizedBox.shrink();
                      
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Управление на обявата',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        context.read<AdDetailsBloc>().add(
                                          AdDetailsNavigateToEdit(ad.id),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Редактирай'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _showDeleteConfirmation(context, ad.id);
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      label: const Text('Изтрий'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Характеристики',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildSpecificationRow('Марка', ad.make),
                          _buildSpecificationRow('Модел', ad.model),
                          _buildSpecificationRow('Година', ad.year.toString()),
                          _buildSpecificationRow('Цвят', ad.color == null || ad.color!.isEmpty ? 'N/A' : ad.color!),
                          _buildSpecificationRow('Мощност', '${ad.hp} к.с.'),
                          _buildSpecificationRow('Обем на двигателя', '${ad.displacement} cc'),
                          _buildSpecificationRow('Пробег', '${ad.mileage} km'),
                          _buildSpecificationRow('Брой врати', ad.doorCount == null || ad.doorCount!.isEmpty ? 'N/A' : ad.doorCount!),
                          _buildSpecificationRow('Брой собственици', ad.ownerCount.toString()),
                          _buildSpecificationRow('Трансмисия', ad.transmissionType ?? 'N/A'),
                          _buildSpecificationRow('Гориво', ad.fuelType ?? 'N/A'),
                          _buildSpecificationRow('Вид каросерия', ad.bodyType ?? 'N/A'),
                          _buildSpecificationRow('Позиция на волана', ad.steeringPosition ?? 'N/A'),
                          _buildSpecificationRow('Брой цилиндри', ad.cylinderCount ?? 'N/A'),
                          _buildSpecificationRow('Задвижване', ad.driveType ?? 'N/A'),
                          _buildSpecificationRow('Състояние', ad.condition ?? 'N/A'),
                          // createdAt is non-nullable in CarAdWithSeller
                            _buildSpecificationRow('Дата на публикуване', _formatDate(ad.createdAt)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), 
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Описание',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(ad.description == null || ad.description!.isEmpty ? 'Няма описание' : ad.description!),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Technical Data Link
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Технически данни',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _launchURL(_getTechnicalDataUrl(ad.make)),
                              icon: const Icon(Icons.info_outline),
                              label: Text('Виж технически данни за ${ad.make}'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Web Calculators
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Калкулатори',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: [
                              _buildCalculatorButton(
                                'Данък МПС',
                                Icons.calculate,
                                'https://www.calculator.bg/1/avtomobil_danak.html',
                              ),
                              _buildCalculatorButton(
                                'Такси при покупка',
                                Icons.receipt_long,
                                'https://www.calculator.bg/1/avtomobili_taksi_danatzi.html',
                              ),
                              _buildCalculatorButton(
                                'Разход на гориво',
                                Icons.local_gas_station,
                                'https://www.calculator.bg/1/razhod_gorivo.html',
                              ),
                              _buildCalculatorButton(
                                'Калкулатор за гуми',
                                Icons.tire_repair,
                                'https://www.calculator.bg/1/avtomobili_gumi.html',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Features
                  if (ad.features.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Опции',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ad.features.map((feature) {
                                return Chip(
                                  label: Text(feature),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Owner Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Връзка с продавача',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone),
                              const SizedBox(width: 8),
                              Text(ad.phone ?? ''),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.phone),
                                onPressed: () {
                                  context.read<AdDetailsBloc>().add(
                                        AdDetailsCallOwner(ad.phone ?? ''),
                                      );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 8),
                              Text('${ad.region ?? ''}${ad.city != null ? (ad.region != null ? ', ' : '') + ad.city! : ''}'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Chat button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final user = context.read<AuthCubit>().state;
                                if (user?.uid != null) {
                                  _startChat(
                                    context,
                                    ad.id,
                                    '${ad.make} ${ad.model} ${ad.title}',
                                    ad.seller.id,
                                    ad.seller.name.isNotEmpty ? ad.seller.name : ad.seller.email,
                                    ad.seller.phone,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Влезте или се регистрирайте, за да започнете чат.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text('Започни чат'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // See all seller's ads button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                               onPressed: () async {
                                 if (!mounted) return;
                                 final bloc = context.read<AdDetailsBloc>();
                                 
                                 // Use seller name from the ad object (already fetched from backend)
                                 final sellerName = ad.seller.name.isNotEmpty 
                                   ? ad.seller.name 
                                   : ad.seller.email.isNotEmpty 
                                     ? ad.seller.email 
                                     : ad.phone ?? 'Unknown Seller';
                                 
                                 bloc.add(
                                   AdDetailsNavigateToSellerAds(
                                     ad.seller.id,
                                     sellerName,
                                   ),
                                 );
                               },
                              icon: const Icon(Icons.list),
                              label: const Text('Виж всички обяви от продавача'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton(String title, IconData icon, String url) {
    return OutlinedButton(
      onPressed: () => _launchURL(url),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 