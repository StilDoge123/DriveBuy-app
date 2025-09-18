import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/notification_badge.dart';
import 'widgets/sort_section.dart';
import 'widgets/filter_section.dart';
import '../chat/bloc/chat_list_bloc.dart';
import '../chat/bloc/chat_list_event.dart';
import '../chat/bloc/chat_list_state.dart';
import 'bloc/marketplace_bloc.dart';
import 'bloc/marketplace_event.dart';
import 'bloc/marketplace_state.dart';
import 'widgets/car_ad_card.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';
import 'package:drivebuy/presentation/app/bloc/saved_ads_cubit.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _MarketplacePageBody();
  }
}

class _MarketplacePageBody extends StatefulWidget {
  @override
  State<_MarketplacePageBody> createState() => _MarketplacePageBodyState();
}

class _MarketplacePageBodyState extends State<_MarketplacePageBody> {
  final _formKey = GlobalKey<FormState>();
  String? _previousUserId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state;
    final isLoggedIn = user != null;
    final currentUserId = user?.uid;
    final marketplaceBloc = context.read<MarketplaceBloc>();
    final chatListBloc = context.read<ChatListBloc>();
    
    // Check if user changed
    if (_previousUserId != currentUserId) {
      print('🔍 MarketplacePage: User changed from $_previousUserId to $currentUserId');
      _previousUserId = currentUserId;
      
      // Notify ChatListBloc about user change
      chatListBloc.add(ChatListUserChanged(currentUserId));
      
      if (isLoggedIn) {
        context.read<SavedAdsCubit>().fetchSavedAds(user.uid);
        // Add a small delay to ensure services are properly initialized after login
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            chatListBloc.add(const ChatListLoad());
          }
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('DriveBuy'),
        actions: [
          BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, chatState) {
              int unreadCount = 0;
              if (isLoggedIn) {
                unreadCount = context.read<ChatListBloc>().getTotalUnreadCount();
              }
              
              return IconButton(
                icon: NotificationBadge(
                  count: unreadCount,
                  child: const Icon(Icons.chat),
                ),
                onPressed: () {
                  if (isLoggedIn) {
                    marketplaceBloc.add(const MarketplaceNavigateToChatList());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Влезте или се регистрирайте, за да видите чатовете.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    marketplaceBloc.add(const MarketplaceNavigateToLogin());
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assistant),
            onPressed: () {
              marketplaceBloc.add(const MarketplaceNavigateToAIAssistant());
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              if (isLoggedIn) {
                marketplaceBloc.add(const MarketplaceNavigateToUserSavedAds());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Влезте или се регистрирайте, за да видите запазени обяви.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                marketplaceBloc.add(const MarketplaceNavigateToLogin());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (isLoggedIn) {
                marketplaceBloc.add(const MarketplaceNavigateToProfile());
              } else {
                marketplaceBloc.add(const MarketplaceNavigateToLogin());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (isLoggedIn) {
                marketplaceBloc.add(const MarketplaceNavigateToCreateAd());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Влезте или се регистрирайте, за да създадете обява.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                marketplaceBloc.add(const MarketplaceNavigateToLogin());
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
          builder: (context, state) {
            if (state.status == MarketplaceStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == MarketplaceStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Възникна грешка.',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SortSection(),
                const SizedBox(height: 16),
                FilterSection(formKey: _formKey),
                if (state.ads.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Няма намерени обяви.'),
                    ),
                  )
                else
                  ...state.ads.map((ad) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CarAdCard(
                      ad: ad,
                      onTap: () => marketplaceBloc.add(
                        MarketplaceNavigateToAdDetails(ad.id),
                      ),
                    ),
                  )),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.search),
        label: const Text('Търси'),
        onPressed: () {
          if (_formKey.currentState?.validate() ?? true) {
            marketplaceBloc.add(const MarketplaceSearchAds());
          }
        },
      ),
    );
  }
}

