/* import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_storage_repository.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/utils/constants.dart';

class LocalIntakeRepository {
  final LocalStorageRepository _storage;
  final Ref _ref;

  LocalIntakeRepository(this._storage, this._ref);

  /// Get the intake logs key specific to the current user
  String get _intakeLogsKey {
    final authState = _ref.read(authProvider);
    final userId = authState.userId ?? 'guest-user';
    return '${StorageKeys.intakeLogs}_$userId';
  }

  /// Get all intake logs for the current user
  List<IntakeLog> getIntakeLogs() {
    try {
      final logsJson = _storage.getStringList(_intakeLogsKey) ?? [];
      return logsJson
          .map((json) => IntakeLog.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      log('Error loading local intake logs: $e');
      return [];
    }
  }

  /// Save an intake log
  Future<bool> saveIntakeLog(IntakeLog intakeLog) async {
    try {
      final logs = getIntakeLogs();
      
      // Check if the log already exists
      final existingIndex = logs.indexWhere((l) => l.id == intakeLog.id);
      
      if (existingIndex >= 0) {
        // Update existing log
        logs[existingIndex] = intakeLog;
      } else {
        // Add new log
        logs.add(intakeLog);
      }
      
      // Convert logs to JSON strings
      final updatedJson = logs.map((l) => jsonEncode(l.toJson())).toList();
      
      // Save to SharedPreferences
      return await _storage.saveStringList(_intakeLogsKey, updatedJson);
    } catch (e) {
      log('Error saving local intake log: $e');
      return false;
    }
  }

  /// Get intake logs for a specific date range
  List<IntakeLog> getIntakeLogsForDateRange(DateTime start, DateTime end) {
    try {
      final logs = getIntakeLogs();
      
      return logs.where((log) {
        return log.intakeTime.isAfter(start) && 
               log.intakeTime.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      log('Error getting intake logs for date range: $e');
      return [];
    }
  }

  /// Get intake logs for the current week
  List<IntakeLog> getIntakeLogsForCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return getIntakeLogsForDateRange(startOfWeek, endOfWeek);
  }

  /// Get intake logs for the current month
  List<IntakeLog> getIntakeLogsForCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getIntakeLogsForDateRange(startOfMonth, endOfMonth);
  }

  /// Get intake logs grouped by day for charts
  Map<DateTime, List<IntakeLog>> getIntakeLogsGroupedByDay(DateTime start, DateTime end) {
    final logs = getIntakeLogsForDateRange(start, end);
    final Map<DateTime, List<IntakeLog>> grouped = {};
    
    for (var log in logs) {
      final day = DateTime(log.intakeTime.year, log.intakeTime.month, log.intakeTime.day);
      
      if (grouped.containsKey(day)) {
        grouped[day]!.add(log);
      } else {
        grouped[day] = [log];
      }
    }
    
    return grouped;
  }

  /// Get daily intake count for date range
  Map<DateTime, int> getDailyIntakeCount(DateTime start, DateTime end) {
    final groupedLogs = getIntakeLogsGroupedByDay(start, end);
    return groupedLogs.map((key, value) => MapEntry(key, value.length));
  }
}

final localIntakeRepositoryProvider = Provider<LocalIntakeRepository>((ref) {
  final localStorageRepo = ref.watch(localStorageRepositoryProvider);
  return LocalIntakeRepository(localStorageRepo, ref);
}); */