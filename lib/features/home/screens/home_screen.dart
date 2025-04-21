import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/home/screens/home_tab.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';
import 'package:vita_min_control_helper/features/tracking/screens/tracking_screen.dart';
import 'package:vita_min_control_helper/features/knowledge/screens/knowledge_screen.dart';
import 'package:vita_min_control_helper/shared/widgets/guest_mode_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const HomeScreen({super.key, required this.initialTabIndex});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _updateCurrentScreen();
  }

  void _updateCurrentScreen() {
    final authState = ref.read(authProvider);
    final isGuest = authState.isGuest;

    // If user is guest, force Knowledge tab
    if (isGuest && _currentIndex != 3) {
      _currentIndex = 3;
    }

    switch (_currentIndex) {
      case 0:
        _currentScreen = const HomeTab();
        break;
      case 1:
        _currentScreen = const TrackingScreen();
        break;
      case 2:
        _currentScreen = const CourseScreen();
        break;
      case 3:
        _currentScreen = const KnowledgeScreen();
        break;
      default:
        _currentScreen = const HomeTab();
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Сьогоднішні завдання';
      case 1:
        return 'Відстеження';
      case 2:
        return 'Мій курс';
      case 3:
        return 'Куток знань';
      default:
        return 'VitaMin Control';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isGuest = authState.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),

        actions: [
          // Show login button for guests
          if (isGuest)
            TextButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Увійти'),
              onPressed: () {
                context.go('/login');
              },
            ),

          // Show logout button for logged in users
          if (authState.isLoggedIn && !isGuest)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Вийти',
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
        ],
      ),
      body: _currentScreen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // Check if user is in guest mode
          if (isGuest && index != 3) {
            // Show dialog
            GuestModeDialog.show(context);
            return;
          }

          setState(() {
            _currentIndex = index;
            _updateCurrentScreen();

            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/tracking');
                break;
              case 2:
                context.go('/course');
                break;
              case 3:
                context.go('/knowledge');
                break;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Головна',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Відстеження',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Курс',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Знання',
          ),
        ],
      ),
    );
  }
}
