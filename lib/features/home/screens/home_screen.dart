import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/home/screens/home_tab.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';
import 'package:vita_min_control_helper/features/tracking/screens/tracking_screen.dart';
import 'package:vita_min_control_helper/features/knowledge/screens/knowledge_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Метод для визначення поточного індексу на основі child

  void _updateCurrentIndex() {
    final isGuestMode = ref.read(authProvider).isGuestMode;
    if (widget.child is HomeTab) {
      _currentIndex = 0;
    } else if (widget.child is CourseScreen) {
      _currentIndex = isGuestMode ? 3 : 1; // Перевіряємо доступність
    } else if (widget.child is TrackingScreen) {
      _currentIndex = isGuestMode ? 3 : 2; // Перевіряємо доступність
    } else if (widget.child is KnowledgeScreen) {
      _currentIndex = 3;
    }
  }

  String _getAppBarTitle() {
    // Змінюємо заголовки відповідно до потреб
    if (_currentIndex == 0) {
      return 'Сьогоднішні завдання'; // або просто 'Сьогодні'
    } else if (_currentIndex == 1) {
      return 'Мій курс';
    } else if (_currentIndex == 2) {
      return 'Відстеження';
    } else if (_currentIndex == 3) {
      return 'Куток знань';
    }
    return 'VitaMin Control';
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentIndex();
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  Widget build(BuildContext context) {
    final isHomeTab = widget.child is HomeTab;
    final isKnowledgeScreen = widget.child is KnowledgeScreen;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        // Показуємо кнопку "Назад" тільки для екрану "Куток знань"
        leading:
            isKnowledgeScreen
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go('/home');
                  },
                )
                : null,
        actions: [
          // Прибираємо кнопку "Куток знань", оскільки вона вже є в нижній навігації

          // Залишаємо кнопку виходу для авторизованих користувачів
          if (authState.isLoggedIn)
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
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          final isGuestMode = ref.read(authProvider).isGuestMode;

          setState(() {
            if (isGuestMode && (index == 1 || index == 2)) {

              // Показуємо діалогове вікно
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Обмежений доступ'),
                      content: const Text(
                        'Ця функція доступна тільки авторизованим користувачам. '
                        'Будь ласка, увійдіть або зареєструйтесь, щоб отримати доступ.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            } else {
              _currentIndex = index;
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/course');
                  break;
                case 2:
                  context.go('/tracking');
                  break;
                case 3:
                  context.go('/knowledge');
                  break;
              }
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
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Курс',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Відстеження',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Знання',
          ),
        ],
      ),
      floatingActionButton:
          isHomeTab
              ? FloatingActionButton(
                onPressed: () {
                  // Show dialog to add one-time medication intake
                  if (authState.isGuestMode) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
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
                  } else {
                    // Add one-time intake logic here
                  }
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
