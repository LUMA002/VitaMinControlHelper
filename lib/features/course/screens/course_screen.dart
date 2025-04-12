import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';
import 'package:vita_min_control_helper/features/course/screens/add_edit_medication_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late List<Reminder> _reminders;
  late List<Supplement> _supplements;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // In a real app, this would load from a repository
    _reminders = MockData.getReminders(MockData.defaultUser.id);
    _supplements = MockData.supplements;
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  String _formatFrequency(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.daily:
        return 'Щодня';
      case ReminderFrequency.weekly:
        return 'Щотижня';
      case ReminderFrequency.asNeeded:
        return 'За потреби';
      default:
        return '';
    }
  }

  String _formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return 'Час не вказано';
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _reminders.isEmpty
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditMedicationScreen(),
                        ),
                      ).then((_) => setState(() => _loadData()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Додати препарат'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  //padding: const EdgeInsets.all(16),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
              final reminder = _reminders[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      _getSupplementName(reminder.supplementId)[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(_getSupplementName(reminder.supplementId)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_formatFrequency(reminder.frequency)}, ${reminder.quantity} ${reminder.unit}'),
                      if (reminder.timeToTake != null)
                        Text('Час прийому: ${_formatTime(reminder.timeToTake)}'),
                      Text('Залишилось: ${reminder.stockAmount} ${reminder.unit}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditMedicationScreen(
                            reminder: reminder,
                          ),
                        ),
                      );
                    },
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditMedicationScreen(),
                        ),
                      ).then((_) => setState(() => _loadData()));
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
    );
  }
}