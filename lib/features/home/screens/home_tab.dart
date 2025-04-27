import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/intake_repository.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_reminder_repository.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  List<Reminder> _reminders = [];
  List<Supplement> _supplements = [];
  List<Reminder> _todayReminders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load supplements from the API
      final supplementRepo = ref.read(supplementRepositoryProvider);
      final supplements = await supplementRepo.getSupplements();

      // Load reminders from local storage
      await _loadLocalReminders();

      setState(() {
        _supplements = supplements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Помилка завантаження даних: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLocalReminders() async {
    try {
      final localReminderRepo = ref.read(localReminderRepositoryProvider);

      // Get all reminders and filter today's reminders
      final reminders = localReminderRepo.getReminders();

      setState(() {
        _reminders = reminders;
        _filterTodayReminders();
      });

      // Also update the provider
      ref.read(localRemindersProvider.notifier).state = reminders;
    } catch (e) {
      log('Error loading local reminders: $e');
      setState(() {
        _reminders = [];
        _todayReminders = [];
      });
    }
  }

  void _filterTodayReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _todayReminders =
        _reminders.where((reminder) {
          if (reminder.nextReminder == null) return false;
          final reminderDate = DateTime(
            reminder.nextReminder!.year,
            reminder.nextReminder!.month,
            reminder.nextReminder!.day,
          );
          return reminderDate.isAtSameMomentAs(today);
        }).toList();

    // Sort by time
    _todayReminders.sort((a, b) {
      if (a.timeToTake == null && b.timeToTake == null) return 0;
      if (a.timeToTake == null) return 1;
      if (b.timeToTake == null) return -1;

      final aMinutes = a.timeToTake!.hour * 60 + a.timeToTake!.minute;
      final bMinutes = b.timeToTake!.hour * 60 + b.timeToTake!.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  Future<void> _markAsTaken(Reminder reminder) async {
    try {
      log('Marking reminder ${reminder.id} as taken');

      final localReminderRepo = ref.read(localReminderRepositoryProvider);
      final intakeRepo = ref.read(intakeRepositoryProvider);

      // Mark reminder as taken locally (this also cancels the notification)
      await localReminderRepo.markReminderAsTaken(reminder.id);

      // Переконуємося, що unit не буде null
      final safeUnit = reminder.unit;
      final supplementName = _getSupplementName(reminder.supplementId);

      // Create an intake log and send directly to API
      final now = DateTime.now();

      try {
        await intakeRepo.addIntakeLog(
          reminder.supplementId,
          now,
          quantity:
              reminder.quantity, // Use the actual quantity from the reminder
          dosage: reminder.dosage ?? 0,
          unit: safeUnit,
        );
        log(
          'Intake log successfully added to API for supplement: $supplementName',
        );
      } catch (e) {
        log('Error saving intake log to API: $e');
        // We'll just show the error but continue with UI updates
      }

      // Update the UI
      await _loadLocalReminders();

      // After all the async operations
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$supplementName відмічено як прийнятий'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Тут обробляємо тільки критичні помилки, які перешкоджають роботі
      log('Critical error marking reminder as taken: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /* void _showAddSingleIntakeDialog() {
    // ...existing code...
  } */

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Спробувати знову'),
            ),
          ],
        ),
      );
    }

    return _todayReminders.isEmpty
        ? Center(
          child: Text(
            'На сьогодні немає запланованих прийомів',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
        : RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _todayReminders.length,
            itemBuilder: (context, index) {
              final reminder = _todayReminders[index];
              final isCompleted = reminder.isConfirmed;
              final supplementName = _getSupplementName(reminder.supplementId);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isCompleted
                                ? Colors.green.shade100
                                : Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.access_time,
                          color:
                              isCompleted
                                  ? Colors.green
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        supplementName,
                        style: TextStyle(
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        reminder.timeToTake != null
                            ? '${reminder.dosage ?? reminder.quantity} ${reminder.unit} о ${reminder.timeToTake!.hour.toString().padLeft(2, '0')}:${reminder.timeToTake!.minute.toString().padLeft(2, '0')}'
                            : '${reminder.dosage ?? reminder.quantity} ${reminder.unit} (час не вказано)',
                      ),
                      trailing:
                          isCompleted
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () => _markAsTaken(reminder),
                                tooltip: 'Позначити як прийнятий',
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
  }
}
