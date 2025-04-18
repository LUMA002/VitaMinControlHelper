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
import 'package:vita_min_control_helper/features/course/screens/add_edit_medication_screen.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true, // Додаємо логування для налагодження
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
          // Extract initialTabIndex from routes
          int initialTabIndex = 0;
          final location = state.uri.path;
          if (location == '/course') {
            initialTabIndex = 2;
          } else if (location == '/tracking') {
            initialTabIndex = 1;
          } else if (location == '/knowledge') {
            initialTabIndex = 3;
          }

          return HomeScreen(initialTabIndex: initialTabIndex);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeTab(),
          ),
          // Course tab
          GoRoute(
            path: '/course',
            builder: (context, state) => const CourseScreen(),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const TrackingScreen(),
          ),
          // Knowledge tab
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const KnowledgeScreen(),
          ),
        ],
      ),

      // Medication screens (outside the shell)
      GoRoute(
        path: '/add-medication',
        builder: (context, state) => const AddEditMedicationScreen(),
      ),
      GoRoute(
        path: '/edit-medication',
        builder: (context, state) {
          final reminder = state.extra as Reminder?;
          return AddEditMedicationScreen(reminder: reminder);
        },
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Сторінку не знайдено: ${state.uri.path}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Повернутися на головну'),
                ),
              ],
            ),
          ),
        ),
  );
});
