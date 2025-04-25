import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/intake_repository.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_intake_repository.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  List<Supplement> _supplements = [];
  DateTime _selectedDate = DateTime.now();
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
      // load supplements from the API
      final supplementRepo = ref.read(supplementRepositoryProvider);
      final supplements = await supplementRepo.getSupplements();

      // завантаження даних про прийом локально
      final intakeRepo = ref.read(intakeRepositoryProvider);
      final localIntakeRepo = ref.read(localIntakeRepositoryProvider);

      //  з API
      List<IntakeLog> intakeLogs = [];
      try {
        intakeLogs = await intakeRepo.getIntakeLogs();
        log("Loaded ${intakeLogs.length} intake logs from API");
      } catch (e) {
        log("Failed to load intake logs from API: $e");
        // Якщо API недоступний, використовуємо локальні дані
        intakeLogs = await localIntakeRepo.getIntakeLogs();
        log("Loaded ${intakeLogs.length} intake logs from local storage");
      }

      setState(() {
        _supplements = supplements;

        // _intakeLogs = intakeLogs; //логи у стейті (завантажені дані)
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Помилка завантаження даних: ${e.toString()}';
        _isLoading = false;
      });
    }
  }


  // mb temporary remake only with week optipon
  DateTime _getStartDate() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Тиждень':
        // start from Monday of the current week
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
      case 'Місяць':
        // start from the first day of the month
        return DateTime(now.year, now.month, 1);
      case 'Рік':
        // start from the first day of the year
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
    }
  }

  DateTime _getEndDate() {
    final startDate = _getStartDate();

    switch (_selectedPeriod) {
      case 'Тиждень':
        return startDate.add(const Duration(days: 6));
      case 'Місяць':
        // Last day of the current month
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      case 'Рік':
        // Last day of the current year
        return DateTime(_selectedDate.year, 12, 31);
      default:
        return startDate.add(const Duration(days: 6));
    }
  }

  List<DateTime> _getDatesInRange() {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    final dayCount = endDate.difference(startDate).inDays + 1;
    return List.generate(
      dayCount,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  Map<DateTime, int> _getDailyIntakeCount() {
    final localIntakeRepo = ref.read(localIntakeRepositoryProvider);
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    // Filter by selected supplement if one is selected
    final dailyCounts = localIntakeRepo.getDailyIntakeCount(startDate, endDate);

    // If no supplement is selected, return all counts
    if (_selectedSupplementId == null) {
      return dailyCounts;
    }

    // Filter log entries by the selected supplement
    final logs =
        localIntakeRepo
            .getIntakeLogsForDateRange(startDate, endDate)
            .where((log) => log.userSupplementId == _selectedSupplementId)
            .toList();

    final Map<DateTime, int> filteredCounts = {};
    for (var log in logs) {
      final day = DateTime(
        log.intakeTime.year,
        log.intakeTime.month,
        log.intakeTime.day,
      );
      filteredCounts[day] = (filteredCounts[day] ?? 0) + 1;
    }

    return filteredCounts;
  }

  Map<String, int> _getSupplementIntakeCount() {
    final localIntakeRepo = ref.read(localIntakeRepositoryProvider);
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    final logs = localIntakeRepo.getIntakeLogsForDateRange(startDate, endDate);
    final Map<String, int> supplementCounts = {};

    for (var log in logs) {
      final supplementName = _getSupplementName(log.userSupplementId);
      supplementCounts[supplementName] =
          (supplementCounts[supplementName] ?? 0) + 1;
    }

    return supplementCounts;
  }

  List<BarChartGroupData> _getBarGroups(BuildContext context) {
    final theme = Theme.of(context);
    final dailyCounts = _getDailyIntakeCount();
    final dates = _getDatesInRange();
    final List<BarChartGroupData> groups = [];

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final count = dailyCounts[date] ?? 0;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: theme.colorScheme.primary,
              width: _selectedPeriod == 'Рік' ? 8 : 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  String _getDateLabel(int index) {
    final dates = _getDatesInRange();
    if (index >= 0 && index < dates.length) {
      final date = dates[index];

      switch (_selectedPeriod) {
        case 'Тиждень':
          return DateFormat('EE').format(date); // Mon, Tue, etc.
        case 'Місяць':
          return date.day.toString();
        case 'Рік':
          return DateFormat('MMM').format(date); // Jan, Feb, etc.
        default:
          return DateFormat('d').format(date);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final supplementCounts = _getSupplementIntakeCount();
    final barGroups = _getBarGroups(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Період:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                      });
                    }
                  },
                  items:
                      _periods.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Supplement filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Добавка:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String?>(
                  value: _selectedSupplementId,
                  hint: const Text('Всі добавки'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSupplementId = newValue;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Всі добавки'),
                    ),
                    ..._supplements.map<DropdownMenuItem<String>>((supplement) {
                      return DropdownMenuItem<String>(
                        value: supplement.id,
                        child: Text(supplement.name),
                      );
                    }), //.toList(),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bar chart
            Text(
              'Прийоми добавок за період',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child:
                  barGroups.isEmpty
                      ? const Center(
                        child: Text('Немає даних для відображення'),
                      )
                      : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              barGroups.fold(0.0, (max, group) {
                                final rodMax = group.barRods.fold(
                                  0.0,
                                  (m, rod) => rod.toY > m ? rod.toY : m,
                                );
                                return rodMax > max ? rodMax : max;
                              }) +
                              1, // Add some padding at the top
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (theme) {
                                return Theme.of(context).colorScheme.primary.withValues(
                                  alpha: 0.8,
                                );
                              },
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final count = rod.toY.toInt();
                                final date = _getDatesInRange()[groupIndex];
                                return BarTooltipItem(
                                  '${DateFormat('d MMM').format(date)}\n$count прийомів',
                                  TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      _getDateLabel(value.toInt()),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                          ),
                          barGroups: barGroups,
                        ),
                      ),
            ),

            const SizedBox(height: 24),

            // Supplement statistics
            Text('Статистика по добавках', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child:
                  supplementCounts.isEmpty
                      ? const Center(
                        child: Text('Немає даних для відображення'),
                      )
                      : ListView(
                        children: () {
                          final entries = supplementCounts.entries.toList();
                          entries.sort((a, b) => b.value.compareTo(a.value));
                          return entries.map((entry) {
                            final percentage =
                                supplementCounts.values.sum == 0
                                    ? 0.0
                                    : entry.value /
                                        supplementCounts.values.sum *
                                        100;

                            return ListTile(
                              title: Text(entry.key),
                              subtitle: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                              trailing: Text(
                                '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList();
                        }(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

extension IterableSum on Iterable<int> {
  int get sum => fold(0, (a, b) => a + b);
}
