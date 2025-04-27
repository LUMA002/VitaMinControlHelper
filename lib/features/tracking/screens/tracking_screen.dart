import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/intake_repository.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  List<Supplement> _supplements = [];
  String? _selectedSupplementId;
  bool _isLoading = true;
  String? _error;

  final List<String> _periods = ['Тиждень', 'Місяць', 'Рік'];
  String _selectedPeriod = 'Тиждень';
  final DateTime _selectedDate = DateTime.now();

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
        // Include the entire last day (23:59:59)
        return DateTime(
          startDate.year,
          startDate.month,
          startDate.day + 6,
          23,
          59,
          59,
          999,
        );
      case 'Місяць':
        // Last day of the current month (also include full day)
        final lastDay = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
        );
        return DateTime(
          lastDay.year,
          lastDay.month,
          lastDay.day,
          23,
          59,
          59,
          999,
        );
      case 'Рік':
        // Last day of the current year (also include full day)
        return DateTime(_selectedDate.year, 12, 31, 23, 59, 59, 999);
      default:
        return DateTime(
          startDate.year,
          startDate.month,
          startDate.day + 6,
          23,
          59,
          59,
          999,
        );
    }
  }

  List<DateTime> _getDatesInRange() {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    final dayCount = endDate.difference(startDate).inDays + 1;

    // Обмежуємо кількість дат для відображення при виборі "Рік"
    if (_selectedPeriod == 'Рік') {
      // Групуємо по місяцях замість днів
      List<DateTime> monthDates = [];
      for (int month = 1; month <= 12; month++) {
        monthDates.add(
          DateTime(_selectedDate.year, month, 15),
        ); // Середина кожного місяця
      }
      return monthDates;
    }
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

  // Modified to use the API repository with async methods
  Future<Map<DateTime, int>> _getDailyIntakeCount() async {
    final intakeRepo = ref.read(intakeRepositoryProvider);
    final startDate = _getStartDate();
    final endDate = _getEndDate();


  log('Date range for $_selectedPeriod: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
    // Always fetch fresh data first
    final logs = await intakeRepo.getIntakeLogsForDateRange(startDate, endDate);

    // Group by day regardless of supplement selection
    final Map<DateTime, int> counts = {};
    for (var log in logs) {
      // Only include selected supplement if one is selected
      if (_selectedSupplementId != null &&
          log.userSupplementId != _selectedSupplementId) {
        continue;
      }

      final day = DateTime(
        log.intakeTime.year,
        log.intakeTime.month,
        log.intakeTime.day,
      );

      counts[day] = (counts[day] ?? 0) + 1;
    }

    // For year view, group by month
    if (_selectedPeriod == 'Рік') {
      final Map<DateTime, int> monthlyCounts = {};
      for (var entry in counts.entries) {
        final monthDate = DateTime(entry.key.year, entry.key.month, 15);
        monthlyCounts[monthDate] =
            (monthlyCounts[monthDate] ?? 0) + entry.value;
      }
      return monthlyCounts;
    }

    return counts;
  }

  // Modified to use the API repository with async methods
  Future<Map<String, int>> _getSupplementIntakeCount() async {
    final intakeRepo = ref.read(intakeRepositoryProvider);
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    final logs = await intakeRepo.getIntakeLogsForDateRange(startDate, endDate);
    final Map<String, int> supplementCounts = {};

    for (var log in logs) {
      final supplementName = _getSupplementName(log.userSupplementId);
      supplementCounts[supplementName] =
          (supplementCounts[supplementName] ?? 0) + 1;
    }

    return supplementCounts;
  }

  List<BarChartGroupData> _getBarGroups(
    BuildContext context,
    Map<DateTime, int> dailyCounts,
  ) {
    final theme = Theme.of(context);
    final dates = _getDatesInRange();

    return dates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final count = dailyCounts[date] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _getPieSections(
    BuildContext context,
    Map<String, int> supplementCounts,
  ) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiaryContainer,
      Colors.amber,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.indigo,
    ];

    final sortedEntries =
        supplementCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 10 supplements
    final entries = sortedEntries.take(10).toList();
    final total = entries.fold(0, (sum, entry) => sum + entry.value);

    if (total == 0) return [];

    return entries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final percentage = entry.value / total * 100;

      // Розташування значків на однаковій відстані від центру, але під різними кутами
      // для запобігання накладанню при однакових відсотках
      final double badgeOffset = 1.2;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // Розміщуємо значки в рівномірно розподілених позиціях,
        // навіть якщо сегменти незбалансовані за розміром
        badgeWidget: _Badge(
          entry.key,
          size: 55,
          borderColor: colors[index % colors.length],
        ),
        badgePositionPercentageOffset: badgeOffset,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              style: TextStyle(color: theme.colorScheme.error),
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

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Тільки TabBar без AppBar
          const TabBar(tabs: [Tab(text: 'Щоденно'), Tab(text: 'Добавки')]),
          // Решта контенту
          Expanded(
            child: TabBarView(
              children: [_buildDailyTab(theme), _buildSupplementsTab(theme)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(theme),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<DateTime, int>>(
              future: _getDailyIntakeCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Помилка завантаження даних: ${snapshot.error}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }

                final dailyCounts = snapshot.data ?? {};
                final barGroups = _getBarGroups(context, dailyCounts);

                if (barGroups.isEmpty) {
                  return const Center(
                    child: Text('Немає даних для відображення'),
                  );
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY:
                        barGroups.fold(0.0, (max, group) {
                          final groupMax = group.barRods.fold(
                            0.0,
                            (max, rod) => rod.toY > max ? rod.toY : max,
                          );
                          return groupMax > max ? groupMax : max;
                        }) +
                        1,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor:
                            (group) => Theme.of(context).colorScheme.primary,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = _getDatesInRange()[group.x];
                          return BarTooltipItem(
                            '${date.day}.${date.month}: ${rod.toY.toInt()} прийомів',
                            TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
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
                            final index = value.toInt();
                            if (index < 0 ||
                                index >= _getDatesInRange().length) {
                              return const SizedBox();
                            }
                            final date = _getDatesInRange()[index];
                            switch (_selectedPeriod) {
                              case 'Тиждень':
                                final weekdays = [
                                  'Пн',
                                  'Вт',
                                  'Ср',
                                  'Чт',
                                  'Пт',
                                  'Сб',
                                  'Нд',
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(weekdays[index % 7]),
                                );
                              case 'Місяць':
                                // Only show every few days
                                if (index % 3 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('${date.day}'),
                                  );
                                }
                                return const SizedBox();
                              case 'Рік':
                                final months = [
                                  'С',
                                  'Л',
                                  'Б',
                                  'К',
                                  'Т',
                                  'Ч',
                                  'Л',
                                  'С',
                                  'В',
                                  'Ж',
                                  'Л',
                                  'Г',
                                ];
                                if (date.day == 15) {
                                  // Show only middle of month
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(months[date.month - 1]),
                                  );
                                }
                                return const SizedBox();
                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(value.toInt().toString()),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: barGroups,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplementsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilter(theme),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: _getSupplementIntakeCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Помилка завантаження даних: ${snapshot.error}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }

                final supplementCounts = snapshot.data ?? {};

                if (supplementCounts.isEmpty) {
                  return const Center(
                    child: Text('Немає даних для відображення'),
                  );
                }

                // Сортуємо добавки за кількістю вживань (від більшої до меншої)
                final sortedEntries =
                    supplementCounts.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                final entries = sortedEntries.take(10).toList();
                final total = entries.fold(
                  0,
                  (sum, entry) => sum + entry.value,
                );

                // Створюємо список кольорів для легенди
                final colors = [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiaryContainer,
                  Colors.amber,
                  Colors.green,
                  Colors.purple,
                  Colors.teal,
                  Colors.pink,
                  Colors.brown,
                  Colors.indigo,
                ];

                return Column(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _getPieSections(context, supplementCounts),
                          centerSpaceRadius: 20,
                          sectionsSpace: 0,
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Додаємо легенду
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: .3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Легенда',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Показуємо список добавок з кольоровими маркерами
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    entries.asMap().entries.map((mapEntry) {
                                      final index = mapEntry.key;
                                      final entry = mapEntry.value;
                                      final percentage =
                                          entry.value / total * 100;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color:
                                                    colors[index %
                                                        colors.length],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${entry.key} - ${percentage.toStringAsFixed(1)}%',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Фільтри', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPeriodFilter(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildSupplementFilter(theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Період',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: _selectedPeriod,
      items:
          _periods.map((period) {
            return DropdownMenuItem<String>(value: period, child: Text(period));
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPeriod = value;
          });
        }
      },
    );
  }

  Widget _buildSupplementFilter(ThemeData theme) {
    return DropdownButtonFormField<String?>(
      decoration: InputDecoration(
        labelText: 'Добавка',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: _selectedSupplementId,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Всі добавки'),
        ),
        ..._supplements.map((supplement) {
          return DropdownMenuItem<String?>(
            value: supplement.id,
            child: Text(supplement.name),
          );
        }), //.toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSupplementId = value;
        });
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(this.text, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              text.length > 10 ? text.substring(0, 10) : text,
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
                color:
                    Colors
                        .black87, // Always use dark text on white background for readability
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
