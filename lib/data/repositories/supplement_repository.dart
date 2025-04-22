import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_type.dart';
import 'package:vita_min_control_helper/services/api_service.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class SupplementRepository {
  final Ref _ref;

  SupplementRepository(this._ref);

  Future<List<Supplement>> getSupplements({bool? isGlobal}) async {
    final apiService = _ref.read(apiServiceProvider);
    final responseData = await apiService.getSupplements(isGlobal: isGlobal);

    return responseData.map((json) => Supplement.fromJson(json)).toList();
  }

  Future<Supplement> getSupplement(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();
      final response = await dio.get(
        '${apiService.baseUrl}/Supplements/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 200) {
        return Supplement.fromJson(response.data);
      } else {
        throw Exception('Failed to get supplement');
      }
    } catch (e) {
      throw Exception('Error getting supplement: $e');
    }
  }

  Future<Supplement> createSupplement(
    String name, {
    String? description,
    String? deficiencySymptoms,
    List<String>? typeIds,
    bool isGlobal = false,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'deficiencySymptoms': deficiencySymptoms,
        'typeIds': typeIds ?? [],
        'isGlobal': isGlobal,
      };

      final response = await dio.post(
        '${apiService.baseUrl}/Supplements',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 201) {
        return Supplement.fromJson(response.data);
      } else {
        throw Exception('Failed to create supplement');
      }
    } catch (e) {
      throw Exception('Error creating supplement: $e');
    }
  }

  Future<Supplement> addSupplement(Supplement supplement) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      // Extract relevant data for the API
      final Map<String, dynamic> data = {
        'name': supplement.name,
        'description': supplement.description,
        'deficiencySymptoms': supplement.deficiencySymptoms,
        'typeIds': supplement.types.map((type) => type.id).toList(),
        'isGlobal': false, // Always false for user-created supplements
        'creatorId': supplement.creatorId,
      };

      final response = await dio.post(
        '${apiService.baseUrl}/Supplements',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
          validateStatus:
              (status) => status! < 500, // Accept 4xx errors for debugging
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Successfully added supplement: ${response.data}');
        // Return the supplement with the ID from the server
        final supplementFromServer = Supplement.fromJson(response.data);
        return supplementFromServer;
      } else {
        log(
          'Failed to add supplement: ${response.statusCode}, ${response.data}',
        );
        // If API returns error but we can still use the local supplement
        return supplement;
      }
    } catch (e) {
      log('Exception when adding supplement: $e');
      // If there's an error with the API, we'll store the supplement locally
      // In a real implementation, you'd want to add this to a local database and sync later
      return supplement; // Return the original supplement for now
    }
  }

  Future<void> updateSupplement(
    String id,
    String name, {
    String? description,
    String? deficiencySymptoms,
    List<String>? typeIds,
    bool? isGlobal,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'deficiencySymptoms': deficiencySymptoms,
        'typeIds': typeIds ?? [],
      };

      if (isGlobal != null) {
        data['isGlobal'] = isGlobal;
      }

      final response = await dio.put(
        '${apiService.baseUrl}/Supplements/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update supplement');
      }
    } catch (e) {
      throw Exception('Error updating supplement: $e');
    }
  }

  Future<void> deleteSupplement(String id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final response = await dio.delete(
        '${apiService.baseUrl}/Supplements/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete supplement');
      }
    } catch (e) {
      throw Exception('Error deleting supplement: $e');
    }
  }

  Future<List<SupplementType>> getSupplementTypes() async {
    final apiService = _ref.read(apiServiceProvider);
    final responseData = await apiService.getSupplementTypes();

    return responseData.map((json) => SupplementType.fromJson(json)).toList();
  }

  Future<SupplementType> createSupplementType(String name) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final dio = Dio();

      final Map<String, dynamic> data = {'name': name};

      final response = await dio.post(
        '${apiService.baseUrl}/SupplementTypes',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_ref.read(authProvider).token}'},
        ),
      );

      if (response.statusCode == 201) {
        return SupplementType.fromJson(response.data);
      } else {
        throw Exception('Failed to create supplement type');
      }
    } catch (e) {
      throw Exception('Error creating supplement type: $e');
    }
  }
}

final supplementRepositoryProvider = Provider<SupplementRepository>((ref) {
  return SupplementRepository(ref);
});
