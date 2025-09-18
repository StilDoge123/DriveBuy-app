import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:drivebuy/presentation/app/router/model/base_route.dart';
import 'package:drivebuy/presentation/app/router/router/router.dart';
import 'package:drivebuy/presentation/app/router/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void setupRouter(BaseRoute initialRoute) {
  locator.registerLazySingleton(
    () => GoRouter(
      routes: routes,
      debugLogDiagnostics: true,
      initialLocation: initialRoute.path,
      errorBuilder: (_, __) => const SizedBox.shrink(),
      // redirect: (BuildContext context, GoRouterState state) {
      //   final auth = locator<Auth>();
      //   final loggedIn = auth.isAuthenticated;

      //   final loggingIn = allowedUnauthorisedRoutes.any((route) {
      //     return state.matchedLocation.startsWith(route.basePath);
      //   });

      //   if (!loggedIn) {
      //     return loggingIn
      //         ? null
      //         : auth.hasUser
      //             ? Routes.login.path
      //             : Routes.welcome.path;
      //   }

      //   return null;
      // },
    ),
  );
}

final allowedUnauthorisedRoutes = [
  Routes.login,
  Routes.register,
];
