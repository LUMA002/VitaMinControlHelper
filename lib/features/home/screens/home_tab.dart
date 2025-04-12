import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late List<Reminder> _reminders;
  late List<Supplement> _supplements;
  late List<Reminder> _todayReminders;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // In a real app, this would load from a repository
    _reminders = MockData.getReminders(MockData.defaultUser.id);
    _supplements = MockData.supplements;
    _filterTodayReminders();
  }

  void _filterTodayReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _todayReminders = _reminders.where((reminder) {
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

  void _markAsTaken(Reminder reminder) {
    // In a real app, this would update the repository and create an intake log
    setState(() {
      final index = _todayReminders.indexOf(reminder);
      if (index != -1) {
        _todayReminders[index] = reminder.copyWith(isConfirmed: true);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getSupplementName(reminder.supplementId)} відмічено як прийнятий'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddSingleIntakeDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
    return _todayReminders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'На сьогодні немає запланованих прийомів',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/course');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Додати в курс'),
                ),
              ],
            ),
          )
        : ListView.builder(
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
                        backgroundColor: isCompleted
                            ? Colors.green.shade100
                            : Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.access_time,
                          color: isCompleted
                              ? Colors.green
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        _getSupplementName(reminder.supplementId),
                        style: TextStyle(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        reminder.timeToTake != null
                            ? '${reminder.quantity} ${reminder.unit}, ${DateFormat.Hm().format(DateTime(
                                2023, 1, 1,
                                reminder.timeToTake!.hour,
                                reminder.timeToTake!.minute,
                              ))}'
                            : '${reminder.quantity} ${reminder.unit}, За потреби',
                        style: TextStyle(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (!isCompleted)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _markAsTaken(reminder),
                              icon: const Icon(Icons.check),
                              label: const Text('Прийнято'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
  }
}