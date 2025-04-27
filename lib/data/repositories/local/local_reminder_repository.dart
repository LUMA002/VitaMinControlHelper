import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_storage_repository.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/services/reminder_notification_manager.dart';
import 'package:vita_min_control_helper/utils/constants.dart';

class LocalReminderRepository {
  final LocalStorageRepository _storage;
  final Ref _ref;

  LocalReminderRepository(this._storage, this._ref);

  /// Get the reminders key specific to the current user
  String get _remindersKey {
    final authState = _ref.read(authProvider);
    final userId = authState.userId ?? 'guest-user';
    return '${StorageKeys.reminders}_$userId';
  }

  /// Get all reminders for the current user
  List<Reminder> getReminders() {
    try {
      final remindersJson = _storage.getStringList(_remindersKey) ?? [];
      return remindersJson
          .map((json) => Reminder.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      log('Error loading local reminders: $e');
      return [];
    }
  }

  /// Save a reminder and schedule its notification
  Future<bool> saveReminder(Reminder reminder) async {
    try {
      final reminders = getReminders();

      // Find if the reminder already exists
      final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);

      if (existingIndex >= 0) {
        // Update existing reminder
        reminders[existingIndex] = reminder;
      } else {
        // Add new reminder
        reminders.add(reminder);
      }

      // Convert reminders to JSON strings
      final updatedJson = reminders.map((r) => jsonEncode(r.toJson())).toList();

      // Save to SharedPreferences
      final result = await _storage.saveStringList(_remindersKey, updatedJson);

      // Schedule notification for this reminder
      if (result) {
        final notificationManager = _ref.read(
          reminderNotificationManagerProvider,
        );
        await notificationManager.updateReminderNotification(reminder);
      }

      return result;
    } catch (e) {
      log('Error saving local reminder: $e');
      return false;
    }
  }

  /// Delete a reminder and cancel its notification
  Future<bool> deleteReminder(String id) async {
    try {
      final reminders = getReminders();

      // Cancel the notification first
      final notificationManager = _ref.read(
        reminderNotificationManagerProvider,
      );
      await notificationManager.cancelReminderNotification(id);

      // Remove the reminder
      reminders.removeWhere((r) => r.id == id);

      // Convert reminders to JSON strings
      final updatedJson = reminders.map((r) => jsonEncode(r.toJson())).toList();

      // Save to SharedPreferences
      return await _storage.saveStringList(_remindersKey, updatedJson);
    } catch (e) {
      log('Error deleting local reminder: $e');
      return false;
    }
  }

  /// Update reminder status (mark as taken)
  Future<bool> markReminderAsTaken(String id) async {
    try {
      final reminders = getReminders();

      // Find the reminder to mark as taken
      final index = reminders.indexWhere((r) => r.id == id);

      if (index >= 0) {
        // Update the reminder
        final reminder = reminders[index];
        final updatedReminder = reminder.copyWith(isConfirmed: true);
        reminders[index] = updatedReminder;

        // Cancel the notification
        final notificationManager = _ref.read(
          reminderNotificationManagerProvider,
        );
        await notificationManager.markReminderAsTaken(updatedReminder);

        // Convert reminders to JSON strings
        final updatedJson =
            reminders.map((r) => jsonEncode(r.toJson())).toList();

        // Save to SharedPreferences
        return await _storage.saveStringList(_remindersKey, updatedJson);
      }

      return false;
    } catch (e) {
      log('Error marking reminder as taken: $e');
      return false;
    }
  }

  /// Get reminders for today
  List<Reminder> getTodayReminders() {
    try {
      final reminders = getReminders();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayReminders =
          reminders.where((reminder) {
            if (reminder.nextReminder == null) return false;

            final reminderDate = DateTime(
              reminder.nextReminder!.year,
              reminder.nextReminder!.month,
              reminder.nextReminder!.day,
            );

            return reminderDate.isAtSameMomentAs(today);
          }).toList();

      // Sort by time
      todayReminders.sort((a, b) {
        if (a.timeToTake == null && b.timeToTake == null) return 0;
        if (a.timeToTake == null) return 1;
        if (b.timeToTake == null) return -1;

        final aMinutes = a.timeToTake!.hour * 60 + a.timeToTake!.minute;
        final bMinutes = b.timeToTake!.hour * 60 + b.timeToTake!.minute;
        return aMinutes.compareTo(bMinutes);
      });

      return todayReminders;
    } catch (e) {
      log('Error getting today reminders: $e');
      return [];
    }
  }

  /// Reset daily reminders for the next day
  Future<void> resetDailyRemindersForNextDay() async {
    try {
      final reminders = getReminders();

      // Get the notification manager
      final notificationManager = _ref.read(
        reminderNotificationManagerProvider,
      );

      // Reset daily reminders for the next day and get the updated list
      final updatedReminders = await notificationManager.rescheduleForNextDay(
        reminders,
      );

      if (updatedReminders.isNotEmpty) {
        // Convert reminders to JSON strings
        final updatedJson =
            updatedReminders.map((r) => jsonEncode(r.toJson())).toList();

        // Save to SharedPreferences
        await _storage.saveStringList(_remindersKey, updatedJson);

        log('Daily reminders reset for the next day');
      }
    } catch (e) {
      log('Error resetting daily reminders: $e');
    }
  }

  /// Schedule notifications for all reminders
  Future<void> scheduleAllNotifications() async {
    try {
      final reminders = getReminders();

      // Get the notification manager
      final notificationManager = _ref.read(
        reminderNotificationManagerProvider,
      );

      // Schedule notifications for all reminders
      await notificationManager.scheduleAllReminders(reminders);

      log('Scheduled notifications for all reminders');
    } catch (e) {
      log('Error scheduling notifications for all reminders: $e');
    }
  }
}

final localReminderRepositoryProvider = Provider<LocalReminderRepository>((
  ref,
) {
  final localStorageRepo = ref.watch(localStorageRepositoryProvider);
  return LocalReminderRepository(localStorageRepo, ref);
});
