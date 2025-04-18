import 'dart:convert';
import 'package:vita_min_control_helper/data/models/user_supplement.dart';
import 'package:vita_min_control_helper/utils/api_helper.dart';

class UserSupplementRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Future<List<UserSupplement>> getUserSupplements() async {
    final response = await _apiHelper.get('/api/UserSupplements');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => UserSupplement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user supplements');
    }
  }

  Future<UserSupplement> getUserSupplement(String id) async {
    final response = await _apiHelper.get('/api/UserSupplements/$id');

    if (response.statusCode == 200) {
      return UserSupplement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to load user supplement');
    }
  }

  Future<UserSupplement> addUserSupplement(
    String supplementId,
    double? dosage,
    String? unit,
    String? instructions,
  ) async {
    final response = await _apiHelper.post(
      '/api/UserSupplements',
      data: {
        'supplementID': supplementId,
        'defaultDosage': dosage,
        'defaultUnit': unit,
        'instructions': instructions,
      },
    );

    if (response.statusCode == 201) {
      return UserSupplement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to add user supplement');
    }
  }

  Future<UserSupplement> updateUserSupplement(
    String id,
    double? dosage,
    String? unit,
    String? instructions,
  ) async {
    final response = await _apiHelper.put(
      '/api/UserSupplements/$id',
      data: {
        'defaultDosage': dosage,
        'defaultUnit': unit,
        'instructions': instructions,
      },
    );

    if (response.statusCode == 200) {
      return UserSupplement.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to update user supplement');
    }
  }

  Future<void> deleteUserSupplement(String id) async {
    final response = await _apiHelper.delete('/api/UserSupplements/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user supplement');
    }
  }
}
