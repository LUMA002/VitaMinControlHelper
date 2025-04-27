import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_reminder_repository.dart';
import 'package:vita_min_control_helper/utils/constants.dart';

/// Service responsible for managing daily reminder resets
class DailyReminderService {
  final Ref _ref;

  DailyReminderService(this._ref);

  /// Check if we need to reset daily reminders
  /// This should be called on app startup
  Future<void> checkAndResetReminders() async {
    try {
      // Get the last time we checked
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString(StorageKeys.lastDayCheck);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTime? lastCheck;
      if (lastCheckString != null) {
        lastCheck = DateTime.parse(lastCheckString);
      }

      final lastCheckDay =
          lastCheck != null
              ? DateTime(lastCheck.year, lastCheck.month, lastCheck.day)
              : null;

      // If we haven't checked today, reset reminders
      if (lastCheckDay == null || !lastCheckDay.isAtSameMomentAs(today)) {
        log('Last check was not today, resetting daily reminders');

        // Update the last check time
        await prefs.setString(
          StorageKeys.lastDayCheck,
          today.toIso8601String(),
        );

        // Reset daily reminders for next day
        final localReminderRepo = _ref.read(localReminderRepositoryProvider);
        await localReminderRepo.resetDailyRemindersForNextDay();

        log('Daily reminders reset complete');
      } else {
        log('Already checked reminders today, no need to reset');

        // Schedule notifications for any reminders that might have been missed
        final localReminderRepo = _ref.read(localReminderRepositoryProvider);
        await localReminderRepo.scheduleAllNotifications();
      }
    } catch (e) {
      log('Error checking and resetting daily reminders: $e');
    }
  }
}

// Provider for the DailyReminderService
final dailyReminderServiceProvider = Provider<DailyReminderService>((ref) {
  return DailyReminderService(ref);
});
