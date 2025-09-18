import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:drivebuy/presentation/screens/ad_details/ad_details_page.dart';
import 'package:drivebuy/presentation/screens/auth/login/login_page.dart';
import 'package:drivebuy/presentation/screens/auth/register/register_page.dart';
import 'package:drivebuy/presentation/screens/chat/chat_list_page.dart';
import 'package:drivebuy/presentation/screens/create_ad/create_ad_page.dart';
import 'package:drivebuy/presentation/screens/marketplace/marketplace_page.dart';
import 'package:drivebuy/presentation/screens/profile/user_info_page.dart';
import 'package:drivebuy/presentation/screens/user_listed_ads/user_listed_ads_page.dart';
import 'package:drivebuy/presentation/screens/user_saved_ads/user_saved_ads_page.dart';
import 'package:drivebuy/presentation/screens/profile/edit_user_page.dart';
import 'package:go_router/go_router.dart';
import 'package:drivebuy/presentation/screens/ai_assistant/ai_assistant_page.dart';
import 'package:drivebuy/presentation/screens/chat/chat_page.dart';
import 'package:drivebuy/domain/models/chat_user.dart';
import 'package:drivebuy/presentation/screens/seller_ads/seller_ads_page.dart';
import 'package:drivebuy/presentation/screens/edit_ad/edit_ad_page.dart';

final routes = [
  GoRoute(
    name: Routes.marketplace.name,
    path: Routes.marketplace.path,
    builder: (_, __) => const MarketplacePage(),
  ),
  GoRoute(
    name: Routes.adDetails.name,
    path: Routes.adDetails.path,
    builder: (context, state) {
      final adId = int.parse(state.pathParameters['id']!);
      return AdDetailsPage(adId: adId);
    },
  ),
  GoRoute(
    name: Routes.createAd.name,
    path: Routes.createAd.path,
    builder: (_, __) => const CreateAdPage(),
  ),
  GoRoute(
    name: Routes.userProfile.name,
    path: Routes.userProfile.path,
    builder: (_, __) => const UserInfoPage(),
  ),
  GoRoute(
    name: Routes.login.name,
    path: Routes.login.path,
    builder: (_, __) => const LoginPage(),
  ),
  GoRoute(
    name: Routes.register.name,
    path: Routes.register.path,
    builder: (_, __) => const RegisterPage(),
  ),
  GoRoute(
    name: Routes.userListedAds.name,
    path: Routes.userListedAds.path,
    builder: (_, __) => const UserListedAdsPage(),
  ),
  GoRoute(
    name: Routes.userSavedAds.name,
    path: Routes.userSavedAds.path,
    builder: (_, __) => const UserSavedAdsPage(),
  ),
  GoRoute(
    name: Routes.editUser.name,
    path: Routes.editUser.path,
    builder: (_, __) => const EditUserPage(),
  ),
  GoRoute(
    name: Routes.aiAssistant.name,
    path: Routes.aiAssistant.path,
    builder: (_, __) => const AiAssistantPage(),
  ),
  GoRoute(
    name: Routes.chatList.name,
    path: Routes.chatList.path,
    builder: (_, __) => const ChatListPage(),
  ),
  GoRoute(
    name: Routes.chat.name,
    path: '/chat/:chatId',
    builder: (context, state) {
      final chatId = int.parse(state.pathParameters['chatId']!);
      final extra = state.extra as Map<String, dynamic>?;
      final adId = extra?['adId'] as int? ?? 0;
      final adTitle = extra?['adTitle'] as String? ?? '';
      final otherUser = extra?['otherUser'] as ChatUser? ?? const ChatUser(id: '', name: '');
      final currentUserId = extra?['currentUserId'] as String?;
      
      return ChatPage(
        chatId: chatId,
        adId: adId,
        adTitle: adTitle,
        otherUser: otherUser,
        currentUserId: currentUserId,
      );
    },
  ),
  GoRoute(
    name: Routes.sellerAds.name,
    path: '/seller-ads/:sellerId',
    builder: (context, state) {
      final sellerId = state.pathParameters['sellerId']!;
      final extra = state.extra as Map<String, dynamic>?;
      final sellerName = extra?['sellerName'] as String? ?? 'Продавач';
      
      return SellerAdsPage(
        sellerId: sellerId,
        sellerName: sellerName,
      );
    },
  ),
  GoRoute(
    name: Routes.editAd.name,
    path: '/edit_ad/:id',
    builder: (context, state) {
      final adId = int.parse(state.pathParameters['id']!);
      return EditAdPage(adId: adId);
    },
  ),
];
