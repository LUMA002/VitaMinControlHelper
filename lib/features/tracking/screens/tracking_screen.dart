import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/data/repositories/intake_repository.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/course/screens/course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  List<Reminder> _reminders = [];
  List<Supplement> _supplements = [];
  List<IntakeLog> _intakeLogs = [];
  DateTime _selectedWeek = DateTime.now();
  String _selectedPeriod = 'Тиждень';
  String? _selectedSupplementId;
  bool _isLoading = true;
  String? _error;

  final List<String> _periods = ['Тиждень', 'Місяць', 'Рік'];

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
      final intakeRepo = ref.read(intakeRepositoryProvider);

      final supplements = await supplementRepo.getSupplements();

     // final intakeLogs = await intakeRepo.getIntakeLogs();

      // Load reminders from local storage
      await _loadLocalReminders();

      setState(() {
        _supplements = supplements;

      //  _intakeLogs = intakeLogs;

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
      });

      // Also update the provider
      ref.read(localRemindersProvider.notifier).state = reminders;
    } catch (e) {
      print('Error loading local reminders: $e');
      // Return empty list in case of error
      setState(() {
        _reminders = [];
      });
    }
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
    // Check if there's an intake log for this reminder on this date
    return _intakeLogs.any(
      (log) =>
          log.userSupplementId == reminder.supplementId &&
          log.createdAt.year == date.year &&
          log.createdAt.month == date.month &&
          log.createdAt.day == date.day,
    );
  }

  List<IntakeLog> _getFilteredLogs() {
    final now = DateTime.now();
    final filtered =
        _intakeLogs.where((log) {
          // Filter by supplement if one is selected
          if (_selectedSupplementId != null &&
              log.userSupplementId != _selectedSupplementId) {
            return false;
          }

          // Filter by period
          switch (_selectedPeriod) {
            case 'Тиждень':
              return log.createdAt.isAfter(
                now.subtract(const Duration(days: 7)),
              );
            case 'Місяць':
              return log.createdAt.isAfter(
                now.subtract(const Duration(days: 30)),
              );
            case 'Рік':
              return log.createdAt.isAfter(
                now.subtract(const Duration(days: 365)),
              );
            default:
              return true;
          }
        }).toList();

    // Sort by date
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered;
  }

  // Calculate statistics for the filtered logs
  Map<String, int> _getDailyIntakeCount() {
    final filteredLogs = _getFilteredLogs();
    final Map<String, int> dailyCounts = {};

    for (var log in filteredLogs) {
      final dateKey = DateFormat('MM-dd').format(log.createdAt);
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
      final supplementName = _getSupplementName(log.userSupplementId);
      supplementCounts[supplementName] =
          (supplementCounts[supplementName] ?? 0) + 1;
    }

    return supplementCounts;
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

    final weekDays = _getWeekDays();
    final theme = Theme.of(context);
    final filteredLogs = _getFilteredLogs();
    final supplementCounts = _getSupplementIntakeCount();
    final barGroups = _getBarGroups();
    final dailyCounts = _getDailyIntakeCount();

    return _reminders.isEmpty
        ? Center(
          child: 
              Text(
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
                    '${DateFormat('d MMM', 'uk').format(weekDays.first)} - '
                    '${DateFormat('d MMM', 'uk').format(weekDays.last)}',
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
                                DateFormat.E('uk').format(day)[0],
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
