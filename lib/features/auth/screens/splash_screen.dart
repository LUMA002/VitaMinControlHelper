// SplashScreen для показу під час завантаження


import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',  // поки без логотипу :)
              width: 100,
              height: 100,
              errorBuilder:
                  (ctx, error, stack) =>
                      const Icon(Icons.medical_services, size: 100),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

