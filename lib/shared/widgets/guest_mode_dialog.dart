import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestModeDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Обмежений доступ'),
            content: const Text(
              'Ця функція доступна тільки авторизованим користувачам. '
              'Увійдіть або зареєструйтеся, щоб отримати повний доступ до додатку.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Залишитись гостем'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                child: const Text('Увійти'),
              ),
            ],
          ),
    );
  }
}
