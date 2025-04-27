import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_storage_repository.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:vita_min_control_helper/services/notification_service.dart';
import 'package:vita_min_control_helper/services/daily_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize timezone data for scheduling notifications
  tz.initializeTimeZones();

  // Initialize notifications
  await NotificationService().initialize();

  // Create the ProviderContainer earlier to use it before runApp
  final container = ProviderContainer(
    overrides: [
      localStorageRepositoryProvider.overrideWith(
        (ref) => LocalStorageRepository(sharedPreferences),
      ),
    ],
  );

  // Check and reset daily reminders
  try {
    final dailyReminderService = container.read(dailyReminderServiceProvider);
    await dailyReminderService.checkAndResetReminders();
    log('Daily reminder check completed');
  } catch (e) {
    log('Error during daily reminder check: $e');
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}
