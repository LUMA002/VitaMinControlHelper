import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late List<IntakeLog> _intakeLogs;
  late List<Supplement> _supplements;
  late String _selectedPeriod = 'Тиждень';
  late String? _selectedSupplementId;
  
  final List<String> _periods = ['Тиждень', 'Місяць', 'Рік'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedSupplementId = null;
  }

  void _loadData() {
    // In a real app, this would load from a repository
    _intakeLogs = MockData.getIntakeLogs(MockData.defaultUser.id);
    _supplements = MockData.supplements;
  }

  String _getSupplementName(String supplementId) {
    final supplement = _supplements.firstWhere(
      (s) => s.id == supplementId,
      orElse: () => Supplement(name: 'Unknown'),
    );
    return supplement.name;
  }

  List<IntakeLog> _getFilteredLogs() {
    final now = DateTime.now();
    final filtered = _intakeLogs.where((log) {
      // Filter by supplement if one is selected
      if (_selectedSupplementId != null && log.supplementId != _selectedSupplementId) {
        return false;
      }
      
      // Filter by period
      switch (_selectedPeriod) {
        case 'Тиждень':
          return log.takenAt.isAfter(now.subtract(const Duration(days: 7)));
        case 'Місяць':
          return log.takenAt.isAfter(now.subtract(const Duration(days: 30)));
        case 'Рік':
          return log.takenAt.isAfter(now.subtract(const Duration(days: 365)));
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
      supplementCounts[supplementName] = (supplementCounts[supplementName] ?? 0) + 1;
    }
    
    return supplementCounts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();
    final supplementCounts = _getSupplementIntakeCount();
    final barGroups = _getBarGroups();
    final dailyCounts = _getDailyIntakeCount();
    
    return filteredLogs.isEmpty
        ? Center(
            child: Text(
              'Немає даних про прийоми.\nПочніть приймати препарати\nдля відображення статистики.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter controls
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Період',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPeriod,
                        items: _periods.map((period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          labelText: 'Препарат',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSupplementId,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Усі'),
                          ),
                          ..._supplements.map((supplement) {
                            return DropdownMenuItem<String?>(
                              value: supplement.id,
                              child: Text(supplement.name),
                            );
                          }),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSupplementId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bar chart for daily intake
                if (barGroups.isNotEmpty) ...[
                  Text(
                    'Кількість прийомів по днях',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: dailyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= 0 && value < dailyCounts.keys.length) {
                                  final date = dailyCounts.keys.elementAt(value.toInt());
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      date,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Supplement count section
                Text(
                  'Статистика по препаратам',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // List of supplements with count
                ...supplementCounts.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        '${entry.value} раз(ів)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Recent intakes section
                Text(
                  'Останні прийоми',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                ...filteredLogs.reversed.take(5).map((log) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(
                          _getSupplementName(log.supplementId)[0],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      title: Text(_getSupplementName(log.supplementId)),
                      subtitle: Text(
                        '${log.quantity} ${log.unit}',
                      ),
                      trailing: Text(
                        DateFormat('dd.MM.yyyy HH:mm').format(log.takenAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
  }
}