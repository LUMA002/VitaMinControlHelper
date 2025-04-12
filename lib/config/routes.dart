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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isGuestMode = authState.isGuestMode;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If not logged in or not in guest mode and not on an auth route, redirect to login
      if (!isLoggedIn && !isGuestMode && !isAuthRoute) {
        return '/login';
      }

      // If logged in or in guest mode and on an auth route, redirect to home
      if ((isLoggedIn || isGuestMode) && isAuthRoute) {
        return '/home';
      }

      // Allow navigation to the requested page
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
          return HomeScreen(child: child);
        },
        routes: [
          // Home tab
          GoRoute(path: '/home', builder: (context, state) => const HomeTab()),
          // Course tab
GoRoute(
  path: '/course',
  builder: (context, state) {
    final isGuestMode = ref.read(authProvider).isGuestMode;
    if (isGuestMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Показуємо діалог
        showDialog(
          context: _rootNavigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Обмежений доступ'),
            content: const Text(
              'Ця функція доступна тільки авторизованим користувачам. Будь ласка, увійдіть або зареєструйтесь.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });

      // Перенаправляємо на "Куток знань"
      return const KnowledgeScreen();
    }
    return const CourseScreen();
  },
),
GoRoute(
  path: '/tracking',
  builder: (context, state) {
    final isGuestMode = ref.read(authProvider).isGuestMode;
    if (isGuestMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Показуємо діалог
        showDialog(
          context: _rootNavigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Обмежений доступ'),
            content: const Text(
              'Ця функція доступна тільки авторизованим користувачам. Будь ласка, увійдіть або зареєструйтесь.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });

      // Перенаправляємо на "Куток знань"
      return const KnowledgeScreen();
    }
    return const TrackingScreen();
  },
),
          // Knowledge tab - добавляємо як частину основної навігації
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const KnowledgeScreen(),
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
