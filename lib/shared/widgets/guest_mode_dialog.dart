import 'package:flutter/material.dart';
class GuestModeDialog extends StatelessWidget {
  const GuestModeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const GuestModeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}