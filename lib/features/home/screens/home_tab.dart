import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      // Get the current user ID
      final authState = ref.read(authProvider);
      final userId = authState.userId ?? 'guest-user';

      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('reminders_$userId') ?? [];

      // Parse reminders
      final reminders =
          remindersJson
              .map((json) => Reminder.fromJson(jsonDecode(json)))
              .toList();

      // Update state
      setState(() {
        _reminders = reminders;
        _filterTodayReminders();
      });

      // Also update the provider
      ref.read(localRemindersProvider.notifier).state = reminders;
    } catch (e) {
      print('Error loading local reminders: $e');
      // Return empty list in case of error
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
      // Get the current user ID
      final authState = ref.read(authProvider);
      final userId = authState.userId ?? 'guest-user';

      // Load existing reminders
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('reminders_$userId') ?? [];

      // Convert reminders to list of objects
      final reminders =
          remindersJson
              .map((json) => Reminder.fromJson(jsonDecode(json)))
              .toList();

      // Find the reminder to mark as taken
      final index = reminders.indexWhere((r) => r.id == reminder.id);

      if (index >= 0) {
        // Update the reminder
        final updatedReminder = reminder.copyWith(isConfirmed: true);
        reminders[index] = updatedReminder;

        // Save back to SharedPreferences
        final updatedJson =
            reminders.map((r) => jsonEncode(r.toJson())).toList();

        await prefs.setStringList('reminders_$userId', updatedJson);

        // Update local state
        setState(() {
          _reminders = reminders;
          final index = _todayReminders.indexOf(reminder);
          if (index != -1) {
            _todayReminders[index] = updatedReminder;
          }
        });

        // Also update the provider
        ref.read(localRemindersProvider.notifier).state = reminders;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_getSupplementName(reminder.supplementId)} відмічено як прийнятий',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /* void _showAddSingleIntakeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Додати одноразовий прийом'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Препарат',
                border: OutlineInputBorder(),
              ),
              items: _supplements.map((supplement) {
                return DropdownMenuItem<String>(
                  value: supplement.id,
                  child: Text(supplement.name),
                );
              }).toList(),
              onChanged: (String? value) {
                // Would be handled in a real app
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Кількість',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Прийом додано'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
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
          child: 
              Text(
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
                        _getSupplementName(reminder.supplementId),
                        style: TextStyle(
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        reminder.timeToTake != null
                            ? '${reminder.quantity} ${reminder.unit} о ${reminder.timeToTake!.hour.toString().padLeft(2, '0')}:${reminder.timeToTake!.minute.toString().padLeft(2, '0')}'
                            : '${reminder.quantity} ${reminder.unit} (час не вказано)',
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
