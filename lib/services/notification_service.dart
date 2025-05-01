import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Instance of Ref for dependency injection
  Ref? _ref;

  // Method to set the Ref instance
  void setRef(Ref ref) {
    _ref = ref;
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Add settings for macOS
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    const InitializationSettings initializationSettingsAll =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsMacOS,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettingsAll,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for iOS and macOS
    await _requestPermissions();

    log('Notification service initialized');
  }

  Future<void> _requestPermissions() async {
    // Додайте запит дозволу для Android 13+
    final android =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android != null) {
      await android.requestNotificationsPermission();
      log('Android notification permissions requested');
    }

    // Існуючі запити для iOS та macOS
    final iOS =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    if (iOS != null) {
      await iOS.requestPermissions(alert: true, badge: true, sound: true);
    }

    final macOS =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    if (macOS != null) {
      await macOS.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // Schedule a notification for a specific reminder
  Future<void> scheduleReminderNotification(
    Reminder reminder, [
    String? supplementName,
  ]) async {
    if (reminder.timeToTake == null) {
      log(
        'Cannot schedule notification: timeToTake is null for reminder ${reminder.id}',
      );
      return;
    }

    try {
      String actualSupplementName = supplementName ?? "Добавка";

      // If no supplementName provided and Ref is available, try to fetch it
      if (supplementName == null && _ref != null) {
        try {
          final supplementRepo = _ref!.read(supplementRepositoryProvider);
          final supplements = await supplementRepo.getSupplements();
          final supplement = supplements.firstWhere(
            (s) => s.id == reminder.supplementId,
            orElse: () => Supplement(name: 'Unknown supplement'),
          );
          actualSupplementName = supplement.name;
          log(
            'Found supplement name: $actualSupplementName for ID: ${reminder.supplementId}',
          );
        } catch (e) {
          log('Error fetching supplement name: $e');
          actualSupplementName = "Добавка";
        }
      }

      // Calculate the next occurrence time for the reminder
      final DateTime now = DateTime.now();
      final DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.timeToTake!.hour,
        reminder.timeToTake!.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      DateTime nextNotificationTime = scheduledDate;
      if (scheduledDate.isBefore(now)) {
        nextNotificationTime = scheduledDate.add(const Duration(days: 1));
      }

      // Convert to timezone-aware DateTime
      final tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(
        nextNotificationTime,
        tz.local,
      );

      log(
        'Scheduling notification for ${actualSupplementName} (${reminder.id}) at $scheduledTzDate',
      );

      // Create Android-specific notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medications',
            importance: Importance.max,
            priority: Priority.high,
          );

      // Create iOS and macOS specific notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Create Linux specific notification details
      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      // Create platform-specific notification details
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
        linux: linuxDetails,
      );

      // Create notification title and body
      final String dosageText =
          reminder.dosage != null
              ? '${reminder.dosage} ${reminder.unit}'
              : '${reminder.quantity} ${reminder.unit}';

      final String title = 'Час прийому ліків';
      final String body = 'Пора прийняти $actualSupplementName: $dosageText';

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        reminder
            .id
            .hashCode, // Use the hash of the reminder ID as notification ID
        title,
        body,
        scheduledTzDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id, // Set the reminder ID as the payload
        matchDateTimeComponents:
            DateTimeComponents.time, // For daily repeating notifications
      );

      log(
        'Notification scheduled successfully for ${actualSupplementName} (${reminder.id})',
      );
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  // Update a scheduled notification
  Future<void> updateReminderNotification(
    Reminder reminder,
    String supplementName,
  ) async {
    // First cancel any existing notification for this reminder
    await cancelReminderNotification(reminder.id);

    // Then schedule a new notification
    await scheduleReminderNotification(reminder, supplementName);
  }

  // Cancel a specific notification by reminder ID
  Future<void> cancelReminderNotification(String reminderId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(reminderId.hashCode);
      log('Notification cancelled for reminder $reminderId');
    } catch (e) {
      log('Error cancelling notification: $e');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      log('All notifications cancelled');
    } catch (e) {
      log('Error cancelling all notifications: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle the notification tap here
    // For example, navigate to a specific screen or show a dialog
    log('Notification tapped: ${response.payload}');

    // Here you could implement navigation to the home screen or a specific screen
    // This would typically be done with a GlobalKey<NavigatorState> or other navigation mechanism
  }
}
