import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/services/api_service.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class IntakeRepository {
  final Ref _ref;

  IntakeRepository(this._ref);

  /// Get all intake logs from the API
  Future<List<IntakeLog>> getIntakeLogs() async {
    final apiService = _ref.read(apiServiceProvider);
    final responseData = await apiService.getIntakeLogs();
    log('Fetched ${responseData.length} intake logs from API');
    return responseData.map((json) => IntakeLog.fromJson(json)).toList();
  }

  /// Get intake logs for a specific date range from the API
  Future<List<IntakeLog>> getIntakeLogsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      // Format dates for API query parameters
      final fromDate = start.toUtc().toIso8601String();
      final toDate = end.toUtc().toIso8601String();

      final response = await dio.get(
        '${apiService.baseUrl}/IntakeLogs',
        queryParameters: {'from': fromDate, 'to': toDate},
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final logs =
            (response.data as List)
                .map((json) => IntakeLog.fromJson(json))
                .toList();
        log('Fetched ${logs.length} intake logs from API for date range');
        return logs;
      } else {
        log(
          'Invalid response format from API for date range query: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      log('Error getting intake logs for date range: $e');
      return [];
    }
  }

  /// Get intake logs for the current week
  Future<List<IntakeLog>> getIntakeLogsForCurrentWeek() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getIntakeLogsForDateRange(startOfWeek, endOfWeek);
  }

  /// Get intake logs for the current month
  Future<List<IntakeLog>> getIntakeLogsForCurrentMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return getIntakeLogsForDateRange(startOfMonth, endOfMonth);
  }

  /// Get intake logs grouped by day for charts
  Future<Map<DateTime, List<IntakeLog>>> getIntakeLogsGroupedByDay(
    DateTime start,
    DateTime end,
  ) async {
    final logs = await getIntakeLogsForDateRange(start, end);
    final Map<DateTime, List<IntakeLog>> grouped = {};

    for (var log in logs) {
      final day = DateTime(
        log.intakeTime.year,
        log.intakeTime.month,
        log.intakeTime.day,
      );

      if (grouped.containsKey(day)) {
        grouped[day]!.add(log);
      } else {
        grouped[day] = [log];
      }
    }

    return grouped;
  }

  /// Get daily intake count for date range
  Future<Map<DateTime, int>> getDailyIntakeCount(
    DateTime start,
    DateTime end,
  ) async {
    final groupedLogs = await getIntakeLogsGroupedByDay(start, end);
    return groupedLogs.map((key, value) => MapEntry(key, value.length));
  }

  Future<IntakeLog> addIntakeLog(
    String userSupplementId,
    DateTime intakeTime, {
    double? dosage,
    String? unit,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final responseData = await apiService.addIntakeLog(
        userSupplementId,
        intakeTime,
        dosage: dosage,
        unit: unit,
      );

      if (responseData != null) {
        log('Successfully added intake log to API');
        return IntakeLog.fromJson(responseData);
      } else {
        throw Exception('Failed to add intake log');
      }
    } catch (e) {
      log('Error adding intake log: $e');
      throw Exception('Error adding intake log: $e');
    }
  }

  Future<void> deleteIntakeLog(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final response = await dio.delete(
        '${apiService.baseUrl}/IntakeLogs/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete intake log');
      }

      log('Successfully deleted intake log from API');
    } catch (e) {
      log('Error deleting intake log: $e');
      throw Exception('Error deleting intake log: $e');
    }
  }
}

final intakeRepositoryProvider = Provider<IntakeRepository>((ref) {
  return IntakeRepository(ref);
});
