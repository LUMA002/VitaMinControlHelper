import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/services/api_service.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class ReminderRepository {
  final Ref _ref;

  ReminderRepository(this._ref);

  Future<List<Reminder>> getReminders() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();
      final response = await dio.get(
        '${apiService.baseUrl}/Reminders',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Reminder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reminders');
      }
    } catch (e) {
      throw Exception('Error fetching reminders: $e');
    }
  }

  Future<Reminder> createReminder({
    required String userSupplementId,
    //required ReminderFrequency frequency,
    TimeOfDay? timeToTake,
    required double quantity,
    required String unit,
    int? stockAmount,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final Map<String, dynamic> data = {
        'userSupplementId': userSupplementId,
       // 'frequency': frequency.toString().split('.').last,
        'quantity': quantity,
        'unit': unit,
      };

      if (timeToTake != null) {
        data['timeHour'] = timeToTake.hour;
        data['timeMinute'] = timeToTake.minute;
      }

      if (stockAmount != null) {
        data['stockAmount'] = stockAmount;
      }

      final response = await dio.post(
        '${apiService.baseUrl}/Reminders',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 201) {
        return Reminder.fromJson(response.data);
      } else {
        throw Exception('Failed to create reminder');
      }
    } catch (e) {
      throw Exception('Error creating reminder: $e');
    }
  }

  Future<void> updateReminder({
    required String id,
    //required ReminderFrequency frequency,
    TimeOfDay? timeToTake,
    required double quantity,
    required String unit,
    int? stockAmount,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final Map<String, dynamic> data = {
      //  'frequency': frequency.toString().split('.').last,
        'quantity': quantity,
        'unit': unit,
      };

      if (timeToTake != null) {
        data['timeHour'] = timeToTake.hour;
        data['timeMinute'] = timeToTake.minute;
      }

      if (stockAmount != null) {
        data['stockAmount'] = stockAmount;
      }

      final response = await dio.put(
        '${apiService.baseUrl}/Reminders/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update reminder');
      }
    } catch (e) {
      throw Exception('Error updating reminder: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final response = await dio.delete(
        '${apiService.baseUrl}/Reminders/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete reminder');
      }
    } catch (e) {
      throw Exception('Error deleting reminder: $e');
    }
  }

  Future<void> markReminderAsTaken(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final response = await dio.post(
        '${apiService.baseUrl}/Reminders/$id/Taken',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark reminder as taken');
      }
    } catch (e) {
      throw Exception('Error marking reminder as taken: $e');
    }
  }
}

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(ref);
});
