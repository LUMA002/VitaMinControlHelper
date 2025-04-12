import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late List<Reminder> _reminders;
  late List<Supplement> _supplements;
  late DateTime _selectedWeek;
  late String _selectedPeriod = 'Тиждень';
  late String? _selectedSupplementId;

  final List<String> _periods = ['Тиждень', 'Місяць', 'Рік'];

  @override
  void initState() {
    super.initState();
    _selectedWeek = DateTime.now();
    _loadData();
    _selectedSupplementId = null;
  }

  void _loadData() {
    _reminders = MockData.getReminders(MockData.defaultUser.id);
    _supplements = MockData.allSupplements;
  }

  List<DateTime> _getWeekDays() {
    final monday = _selectedWeek.subtract(
      Duration(days: _selectedWeek.weekday - 1),
    );
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  bool _wasIntakeTaken(Reminder reminder, DateTime date) {
    // В реальному додатку тут буде перевірка з бази даних
    // Зараз просто випадкове значення для демонстрації
    return reminder.isConfirmed && reminder.nextReminder?.day == date.day;
  }

  List<IntakeLog> _getFilteredLogs() {
    final now = DateTime.now();
    final filtered =
        MockData.getIntakeLogs(MockData.defaultUser.id).where((log) {
          // Filter by supplement if one is selected
          if (_selectedSupplementId != null &&
              log.supplementId != _selectedSupplementId) {
            return false;
          }

          // Filter by period
          switch (_selectedPeriod) {
            case 'Тиждень':
              return log.takenAt.isAfter(now.subtract(const Duration(days: 7)));
            case 'Місяць':
              return log.takenAt.isAfter(
                now.subtract(const Duration(days: 30)),
              );
            case 'Рік':
              return log.takenAt.isAfter(
                now.subtract(const Duration(days: 365)),
              );
            default:
              return true;
          }
        }).toList();

    // Sort by date
    filtered.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    return filtered;
  }

  // Calculate statistics for the filtered logs
  Map<String, int> _getDailyIntakeCount() {
    final filteredLogs = _getFilteredLogs();
    final Map<String, int> dailyCounts = {};

    for (var log in filteredLogs) {
      final dateKey = DateFormat('MM-dd').format(log.takenAt);
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    return dailyCounts;
  }

  List<BarChartGroupData> _getBarGroups() {
    final dailyCounts = _getDailyIntakeCount();
    final groups = <BarChartGroupData>[];

    int index = 0;
    dailyCounts.forEach((date, count) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return groups;
  }

  Map<String, int> _getSupplementIntakeCount() {
    final filteredLogs = _getFilteredLogs();
    final Map<String, int> supplementCounts = {};

    for (var log in filteredLogs) {
      final supplementName = _getSupplementName(log.supplementId);
      supplementCounts[supplementName] =
          (supplementCounts[supplementName] ?? 0) + 1;
    }

    return supplementCounts;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final theme = Theme.of(context);
    final filteredLogs = _getFilteredLogs();
    final supplementCounts = _getSupplementIntakeCount();
    final barGroups = _getBarGroups();
    final dailyCounts = _getDailyIntakeCount();

    return _reminders.isEmpty
        ? Center(
          child: Text(
            'Додайте препарати в розділі "Курс"\nдля відстеження їх прийому',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        )
        : Column(
          children: [
            // Навігація по тижнях
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedWeek = _selectedWeek.subtract(
                          const Duration(days: 7),
                        );
                      });
                    },
                  ),
                  Text(
                    '${DateFormat('d MMM').format(weekDays.first)} - '
                    '${DateFormat('d MMM').format(weekDays.last)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedWeek = _selectedWeek.add(
                          const Duration(days: 7),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),

            // Дні тижня
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    weekDays.map((day) {
                      final isToday =
                          day.day == DateTime.now().day &&
                          day.month == DateTime.now().month &&
                          day.year == DateTime.now().year;
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration:
                              isToday
                                  ? BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                  : null,
                          child: Column(
                            children: [
                              Text(
                                DateFormat('uk').format(day)[0],
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                day.day.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color:
                                      isToday
                                          ? theme.colorScheme.onPrimaryContainer
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const Divider(height: 32),

            // Список препаратів
            Expanded(
              child: ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSupplementName(reminder.supplementId),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:
                              weekDays.map((day) {
                                final taken = _wasIntakeTaken(reminder, day);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Тут буде логіка зміни стану прийому
                                      setState(() {
                                        // Оновлення стану
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary,
                                            width: 2,
                                          ),
                                          color:
                                              taken
                                                  ? theme.colorScheme.primary
                                                  : null,
                                        ),
                                        child:
                                            taken
                                                ? Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onPrimary,
                                                )
                                                : null,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}
