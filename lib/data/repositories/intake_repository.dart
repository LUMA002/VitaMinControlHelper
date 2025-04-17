import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/services/api_service.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class IntakeRepository {
  final Ref _ref;

  IntakeRepository(this._ref);

  Future<List<IntakeLog>> getIntakeLogs() async {
    final apiService = _ref.read(apiServiceProvider);
    final responseData = await apiService.getIntakeLogs();

    return responseData.map((json) => IntakeLog.fromJson(json)).toList();
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
        return IntakeLog.fromJson(responseData);
      } else {
        throw Exception('Failed to add intake log');
      }
    } catch (e) {
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
    } catch (e) {
      throw Exception('Error deleting intake log: $e');
    }
  }
}

final intakeRepositoryProvider = Provider<IntakeRepository>((ref) {
  return IntakeRepository(ref);
});
