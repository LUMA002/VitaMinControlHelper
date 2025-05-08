import 'package:flutter/material.dart';
import 'dart:async';
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
import 'package:vita_min_control_helper/features/auth/screens/splash_screen.dart';                      

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Провайдер для відкладеного роутера
final routerProvider = Provider<GoRouter>((ref) {
  final authStateProvider = ref.watch(authProvider.notifier);

  // Використовуємо refreshListenable для оновлення маршрутизатора при зміні автентифікації
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authStateProvider.stream),
    initialLocation: '/', // Змінюємо на проміжний маршрут
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final isGuest = ref.read(authProvider).isGuest;
      final isLoading = ref.read(authProvider).isLoading;

      // Проміжний шлях для визначення перенаправлення
      final isInitialRoute = state.matchedLocation == '/';

      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Під час завантаження показуємо SplashScreen
      if (isLoading && isInitialRoute) {
        return null; // Залишаємося на '/', який буде показувати SplashScreen
      }

      // Після завантаження - визначаємо правильний маршрут
      if (isInitialRoute) {
        // Якщо користувач авторизований або гість, перенаправляємо на головну/знання
        if (isLoggedIn) return '/home';
        if (isGuest) return '/knowledge';
        // Інакше на логін
        return '/login';
      }

      // Неавторизовані користувачі - тільки на логін чи реєстрацію
      if (!isLoggedIn && !isGuest && !isGoingToAuth) {
        return '/login';
      }

      // Авторизованим користувачам не показуємо логін/реєстрацію
      if (isLoggedIn && isGoingToAuth) {
        return '/home';
      }

      // Гості можуть бачити тільки розділ знань та сторінки авторизації
      if (isGuest &&
          state.matchedLocation != '/knowledge' &&
          state.matchedLocation != '/login' &&
          state.matchedLocation != '/register' &&
          !state.matchedLocation.startsWith('/knowledge/')) {
        return '/knowledge';
      }

      return null; // Немає перенаправлення
    },
    routes: [
      // Проміжний маршрут для SplashScreen
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

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
          GoRoute(path: '/home', builder: (context, state) => const HomeTab()),
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

      // // Medication screens (outside the shell)
      // GoRoute(
      //   path: '/add-medication',
      //   builder: (context, state) => const AddEditMedicationScreen(),
      // ),
      // GoRoute(
      //   path: '/edit-medication',
      //   builder: (context, state) {
      //     final reminder = state.extra as Reminder?;
      //     return AddEditMedicationScreen(reminder: reminder);
      //   },
      // ),
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


// Допоміжний клас для оновлення маршрутизатора при зміні стану автентифікації
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
