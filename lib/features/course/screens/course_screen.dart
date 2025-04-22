import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_reminder_repository.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/features/course/screens/add_edit_medication_screen.dart';


// Local storage provider for reminders
final localRemindersProvider = StateProvider<List<Reminder>>((ref) => []);

class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({super.key});

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {
  List<Reminder> _reminders = [];
  List<Supplement> _supplements = [];
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
      final reminders = localReminderRepo.getReminders();

      setState(() {
        _reminders = reminders;
      });

      // Also update the provider
      ref.read(localRemindersProvider.notifier).state = reminders;
    } catch (e) {
      log('Error loading local reminders: $e');
      setState(() {
        _reminders = [];
      });
    }
  }

  Future<void> _saveLocalReminder(Reminder reminder) async {
    try {
      final localReminderRepo = ref.read(localReminderRepositoryProvider);
      await localReminderRepo.saveReminder(reminder);

      // Reload reminders to update the UI
      await _loadLocalReminders();
    } catch (e) {
      log('Error saving local reminder: $e');
      throw Exception('Failed to save reminder: $e');
    }
  }

  Future<void> _deleteReminder(String id) async {
    try {
      final localReminderRepo = ref.read(localReminderRepositoryProvider);
      await localReminderRepo.deleteReminder(id);

      // Reload reminders to update the UI
      await _loadLocalReminders();
    } catch (e) {
      log('Error deleting local reminder: $e');
      throw Exception('Failed to delete reminder: $e');
    }
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  String _formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return 'Час не вказано';
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

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

    return _reminders.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'У вас ще немає запланованих прийомів.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditMedicationScreen(),
                    ),
                  );

                  if (result != null && result is Reminder) {
                    await _saveLocalReminder(result);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Додати препарат'),
              ),
            ],
          ),
        )
        : Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(_getSupplementName(reminder.supplementId)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Час: ${_formatTime(reminder.timeToTake)}'),
                          Text(
                            'Кількість порцій: ${reminder.quantity} (${reminder.activeIngredientAmount} ${reminder.unit})',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddEditMedicationScreen(
                                        reminder: reminder,
                                      ),
                                ),
                              );

                              if (result != null && result is Reminder) {
                                await _saveLocalReminder(result);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'Видалити нагадування?',
                                      ),
                                      content: Text(
                                        'Ви впевнені, що хочете видалити нагадування для "${_getSupplementName(reminder.supplementId)}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Скасувати'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Видалити'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                await _deleteReminder(reminder.id);
                              }
                            },
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditMedicationScreen(),
                    ),
                  );

                  if (result != null && result is Reminder) {
                    await _saveLocalReminder(result);
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
  }
}
