import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/auth/screens/login_screen.dart';
import 'package:vita_min_control_helper/features/auth/screens/register_screen.dart';
import 'package:vita_min_control_helper/features/home/screens/home_screen.dart';
import 'package:vita_min_control_helper/features/home/screens/home_tab.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';
import 'package:vita_min_control_helper/features/tracking/screens/tracking_screen.dart';
import 'package:vita_min_control_helper/features/knowledge/screens/knowledge_screen.dart';
import 'package:vita_min_control_helper/shared/widgets/guest_mode_dialog.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,

    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isGuest = authState.isGuest;
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not logged in and not a guest, redirect to login
      if (!isLoggedIn && !isGuest && !isGoingToAuth) {
        return '/login';
      }

      // Logged in or guest, prevent access to auth pages
      if ((isLoggedIn || isGuest) && isGoingToAuth) {
        return '/home';
      }

      // Guest users can only access knowledge section
      if (isGuest &&
          state.matchedLocation != '/knowledge' &&
          !state.matchedLocation.startsWith('/knowledge/')) {
        return '/knowledge';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeScreen(initialTabIndex: 0,
          );
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(initialTabIndex: 0),
          ),
          // Course tab
          GoRoute(
            path: '/course',
            builder: (context, state) => const HomeScreen(initialTabIndex: 2),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const HomeScreen(initialTabIndex: 1),
          ),
          // Knowledge tab - доступно для всіх користувачів
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const HomeScreen(initialTabIndex: 3),
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Text('Сторінку не знайдено: ${state.matchedLocation}'),
          ),
        ),
  );
});
