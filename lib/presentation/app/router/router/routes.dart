import 'package:drivebuy/presentation/app/router/model/base_route.dart';

class Routes {
  static const BaseRoute marketplace = BaseRoute(
    name: 'marketplace',
    path: '/marketplace',
  );

  static const BaseRoute adDetails = BaseRoute(
    name: 'adDetails',
    path: '/adDetails',
    pathParameter: 'id',
  );

  static const BaseRoute createAd = BaseRoute(
    name: 'createAd',
    path: '/create_ad',
  );

  static const BaseRoute userProfile = BaseRoute(
    name: 'userProfile',
    path: '/user_profile',
  );

  static const BaseRoute login = BaseRoute(
    name: 'login',
    path: '/login',
  );

  static const BaseRoute register = BaseRoute(
    name: 'register',
    path: '/register',
  );

  static const BaseRoute userListedAds = BaseRoute(
    name: 'userListedAds',
    path: '/user_listed_ads',
  );

  static const BaseRoute userSavedAds = BaseRoute(
    name: 'userSavedAds',
    path: '/user_saved_ads',
  );

  static const BaseRoute editUser = BaseRoute(
    name: 'editUser',
    path: '/edit_user',
  );

  static const BaseRoute aiAssistant = BaseRoute(
    name: 'aiAssistant',
    path: '/ai-assistant',
  );

  static const BaseRoute chatList = BaseRoute(
    name: 'chatList',
    path: '/chats',
  );

  static const BaseRoute chat = BaseRoute(
    name: 'chat',
    path: '/chat',
    pathParameter: 'chatId',
  );

  static const BaseRoute sellerAds = BaseRoute(
    name: 'sellerAds',
    path: '/seller-ads',
    pathParameter: 'sellerId',
  );

  static const BaseRoute editAd = BaseRoute(
    name: 'editAd',
    path: '/edit_ad',
    pathParameter: 'id',
  );
}