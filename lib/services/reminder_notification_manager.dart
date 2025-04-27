import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/services/notification_service.dart';

/// A service that manages scheduling and cancelling notifications for reminders
class ReminderNotificationManager {
  final NotificationService _notificationService;
  final Ref _ref;

  ReminderNotificationManager(this._notificationService, this._ref) {
    // Pass the Ref to the NotificationService
    _notificationService.setRef(_ref);
  }

  /// Schedule a notification for a reminder
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (reminder.timeToTake == null) {
      log(
        'Cannot schedule notification: timeToTake is null for reminder ${reminder.id}',
      );
      return;
    }

    try {
      // Get the supplement name
      final supplementName = await _getSupplementName(reminder.supplementId);

      // Schedule notification with the supplement name
      await _notificationService.scheduleReminderNotification(
        reminder,
        supplementName,
      );

      log(
        'Notification scheduled for reminder ${reminder.id} ($supplementName)',
      );
    } catch (e) {
      log('Error scheduling notification for reminder ${reminder.id}: $e');
    }
  }

  /// Get a supplement name from its ID
  Future<String> _getSupplementName(String supplementId) async {
    try {
      final supplementRepo = _ref.read(supplementRepositoryProvider);
      final supplements = await supplementRepo.getSupplements();

      final supplement = supplements.firstWhere(
        (s) => s.id == supplementId,
        orElse: () => Supplement(name: 'Unknown supplement'),
      );

      return supplement.name;
    } catch (e) {
      log('Error getting supplement name for ID $supplementId: $e');
      return 'Unknown supplement';
    }
  }

  /// Cancel a notification for a reminder
  Future<void> cancelReminderNotification(String reminderId) async {
    await _notificationService.cancelReminderNotification(reminderId);
    log('Notification cancelled for reminder $reminderId');
  }

  /// Update a notification for a reminder
  Future<void> updateReminderNotification(Reminder reminder) async {
    try {
      // Cancel existing notification
      await cancelReminderNotification(reminder.id);

      // Only schedule a new notification if the reminder is not confirmed
      if (!reminder.isConfirmed) {
        // Get the supplement name
        final supplementName = await _getSupplementName(reminder.supplementId);

        // Schedule new notification with the supplement name
        await _notificationService.scheduleReminderNotification(
          reminder,
          supplementName,
        );
      }
    } catch (e) {
      log('Error updating notification for reminder ${reminder.id}: $e');
    }
  }

  /// Schedule notifications for all reminders
  Future<void> scheduleAllReminders(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      // Only schedule notifications for reminders that are not confirmed
      if (!reminder.isConfirmed) {
        await scheduleReminderNotification(reminder);
      }
    }

    log('Scheduled notifications for ${reminders.length} reminders');
  }

  /// Cancel all notifications and reschedule for tomorrow
  Future<List<Reminder>> rescheduleForNextDay(List<Reminder> reminders) async {
    // Cancel all existing notifications
    await _notificationService.cancelAllNotifications();

    // Reset isConfirmed flag for all reminders with daily frequency
    final updatedReminders =
        reminders.map((reminder) {
          if (reminder.frequency == ReminderFrequency.daily) {
            return reminder.copyWith(
              isConfirmed: false,
              nextReminder: DateTime.now().add(const Duration(days: 1)),
            );
          }
          return reminder;
        }).toList();

    // Schedule notifications for all updated reminders
    await scheduleAllReminders(updatedReminders);

    log('Rescheduled notifications for next day');

    // Return the updated reminders for saving
    return updatedReminders;
  }

  /// Mark a reminder as taken and cancel its notification
  Future<void> markReminderAsTaken(Reminder reminder) async {
    // Cancel the notification for this reminder
    await cancelReminderNotification(reminder.id);

    log('Reminder ${reminder.id} marked as taken, notification cancelled');
  }
}

// Provider for the ReminderNotificationManager
final reminderNotificationManagerProvider =
    Provider<ReminderNotificationManager>((ref) {
      return ReminderNotificationManager(NotificationService(), ref);
    });
