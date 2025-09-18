import 'package:drivebuy/data/repositories/ad_repository.dart';
import 'package:drivebuy/data/repositories/auth_repository.dart';
import 'package:drivebuy/data/repositories/user_repository.dart';
import 'package:drivebuy/data/repositories/chat_repository.dart';
import 'package:drivebuy/data/services/ai_assistant_service.dart';
import 'package:drivebuy/presentation/app/bloc/auth_cubit.dart';
import 'package:drivebuy/presentation/app/bloc/saved_ads_cubit.dart';
import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:drivebuy/presentation/app/router/setup.dart';
import 'package:drivebuy/presentation/screens/ai_assistant/bloc/ai_assistant_bloc.dart';
import 'package:drivebuy/presentation/screens/chat/bloc/chat_list_bloc.dart';
import 'package:drivebuy/presentation/screens/chat/bloc/chat_list_event.dart';
import 'package:drivebuy/presentation/screens/chat/bloc/individual_chat_bloc.dart';
import 'package:drivebuy/presentation/screens/marketplace/bloc/marketplace_bloc.dart';
import 'package:drivebuy/presentation/screens/marketplace/bloc/marketplace_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'data/services/dropdown_data_service.dart';
import 'data/services/image_upload_service.dart';
import 'data/services/chat_service.dart';
import 'data/services/cache_service.dart';
import 'data/services/realtime_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/app/network/auth_interceptor.dart';

import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showGlobalError(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

Future<Dio> createDio(AuthRepository authRepository) async {
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor(authRepository.getIdToken));
  return dio;
}

Future<void> setupLocator() async {
  // Create a temporary Dio instance for AuthRepository registration
  final tempDio = Dio();
  locator.registerLazySingleton(() => AuthRepository(dio: tempDio));
  
  // Create the main Dio instance with AuthInterceptor
  final dio = await createDio(locator<AuthRepository>());
  locator.registerSingleton<Dio>(dio);
  
  // Register repositories with the main Dio instance
  locator.registerLazySingleton(() => AdRepository(dio: locator<Dio>()));
  locator.registerLazySingleton(() => UserRepository(dio: locator<Dio>()));
  locator.registerLazySingleton(() => ChatRepository(dio: locator<Dio>()));
  locator.registerLazySingleton(() => DropdownDataService(dio: locator<Dio>()));
  locator.registerLazySingleton(() => ImageUploadService(dio: locator<Dio>()));
  locator.registerLazySingleton(() => ChatService());
  locator.registerLazySingleton(() => CacheService());
  locator.registerLazySingleton(() => RealtimeService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => MarketplaceBloc(
        adRepository: locator<AdRepository>(),
        router: locator<GoRouter>(),
        chatService: locator<ChatService>(),
        userRepository: locator<UserRepository>(),
      ));
  locator.registerSingletonAsync<AiAssistantService>(
      () => AiAssistantService.create());
  locator.registerFactory(() => AiAssistantBloc(
      aiAssistantServiceFuture: locator.getAsync<AiAssistantService>()));
  await locator.allReady();
  
  // Initialize NotificationService
  await locator<NotificationService>().initialize();
  
  // Initialize ChatService with dependencies
  locator<ChatService>().initialize(
    chatRepository: locator<ChatRepository>(),
    userRepository: locator<UserRepository>(),
    adRepository: locator<AdRepository>(),
    realtimeService: locator<RealtimeService>(),
    notificationService: locator<NotificationService>(),
  );
  
  // Start cleanup timers for services
  locator<CacheService>().startCleanupTimer();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    showGlobalError('A framework error occurred: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Caught platform error: $error');
    debugPrintStack(stackTrace: stack);
    showGlobalError('A platform error occurred: $error');
    return true;
  };

  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('⚠️ App will continue without Firebase features');
  }
  
  setupRouter(Routes.marketplace);
  await setupLocator();
  runApp(MyApp(router: locator<GoRouter>()));
}

class MyApp extends StatefulWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ChatListBloc? _chatListBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleAppResume() async {
    try {
      print('🔍 App: Handling app resume - reconnecting realtime and refreshing chat list');
      await locator<RealtimeService>().handleAppResume();
      
      // Trigger a chat list refresh to ensure we have the latest messages
      // This helps sync any messages received while the app was backgrounded
      if (_chatListBloc != null && !_chatListBloc!.isClosed) {
        try {
          _chatListBloc!.add(const ChatListRefresh());
          print('🔍 App: Triggered chat list refresh after app resume');
        } catch (e) {
          print('🔍 App: Error triggering chat list refresh: $e');
          // Non-critical, continue with app resume
        }
      } else {
        print('🔍 App: ChatListBloc not available, skipping refresh');
      }
      
      print('🔍 App: App resume handled successfully');
    } catch (e) {
      print('🔍 App: Error handling app resume: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔍 App: Resumed - attempting to reconnect realtime service');
        // Handle app resume - reconnect realtime service
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
        print('🔍 App: Paused - handling app pause');
        // Handle app pause
        try {
          locator<RealtimeService>().handleAppPause();
        } catch (e) {
          print('🔍 App: Error handling app pause: $e');
        }
        break;
      case AppLifecycleState.detached:
        print('🔍 App: Detached - cleaning up realtime service');
        // Handle app close - cleanup
        try {
          locator<RealtimeService>().disconnect();
        } catch (e) {
          print('🔍 App: Error cleaning up realtime service: $e');
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                AuthCubit(authRepository: locator<AuthRepository>())),
        BlocProvider.value(
            value: locator<MarketplaceBloc>()
              ..add(const MarketplaceLoadAds())),
        BlocProvider(create: (_) => locator<AiAssistantBloc>()),
        BlocProvider(create: (_) => SavedAdsCubit()),
        BlocProvider(create: (_) {
          _chatListBloc = ChatListBloc(
            chatService: locator<ChatService>(),
            userRepository: locator<UserRepository>(),
          );
          return _chatListBloc!;
        }),
        BlocProvider(create: (_) => IndividualChatBloc(
          router: locator<GoRouter>(),
          chatService: locator<ChatService>(),
          userRepository: locator<UserRepository>(),
        )),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'DriveBuy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 6, 92, 9),
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.green,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
          ),
        ),
        routerConfig: widget.router,
      ),
    );
  }
}
