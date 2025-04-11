import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/home/screens/home_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine if we're showing the HomeTab or another screen
    final isHomeTab = widget.child is HomeTab;
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('VitaMin Control'),
        actions: [
          // Knowledge corner button
          IconButton(
            icon: const Icon(Icons.library_books),
            tooltip: 'Куток знань',
            onPressed: () {
              context.go('/knowledge');
            },
          ),
          
          // Logout button (only if logged in)
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
          setState(() {
            _currentIndex = index;
          });
          
          // Navigate based on the selected tab
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
          }
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
        ],
      ),
      floatingActionButton: isHomeTab
          ? FloatingActionButton(
              onPressed: () {
                // Show dialog to add one-time medication intake
                if (authState.isGuestMode) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Обмежений доступ'),
                      content: const Text('Ця функція доступна тільки авторизованим користувачам. Будь ласка, увійдіть або зареєструйтесь.'),
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