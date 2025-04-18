import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/app/app.dart';
//import 'package:hive_flutter/hive_flutter.dart';

// Переконуємося, що програма правильно ініціалізується
void main() {
  // Необхідно для ініціалізації Flutter Binding перед викликом runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (закоментовано, бо використовуємо SharedPreferences)
  //await Hive.initFlutter();

  // Register Hive adapters (we'll implement these later)
  // await Hive.openBox('userData');
  // await Hive.openBox('medications');
  // await Hive.openBox('trackingData');

  // Обгортаємо додаток у ProviderScope для роботи Riverpod
  runApp(const ProviderScope(child: MyApp()));
}
