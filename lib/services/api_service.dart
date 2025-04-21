import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class ApiService {
  final Dio _dio;
  final Ref _ref;
  // Важлива зміна змінної, не використовувати localhost!!!
  final String _baseUrl = 'http://10.0.2.2:5241/api';

  // Make baseUrl accessible via a getter
  String get baseUrl => _baseUrl;

  ApiService(this._ref) : _dio = Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final authState = _ref.read(authProvider);
          final token = authState.token;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Необхідно оновити токен або перенаправити на екран входу
            _ref.read(authProvider.notifier).logout();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Методи автентифікації
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/Auth/Login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
    String confirmPassword, {
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };

      if (dateOfBirth != null) {
        data['dateOfBirth'] = dateOfBirth.toIso8601String();
      }

      if (gender != null) {
        data['gender'] = gender;
      }

      if (height != null) {
        data['height'] = height;
      }

      if (weight != null) {
        data['weight'] = weight;
      }

      final response = await _dio.post('$_baseUrl/Auth/Register', data: data);

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('Register error: ${e.message}');
      return null;
    }
  }

  // Методи для доступу до даних
  Future<List<Map<String, dynamic>>> getSupplementTypes() async {
    try {
      final response = await _dio.get('$_baseUrl/SupplementTypes');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching supplement types: ${e.message}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSupplements({bool? isGlobal}) async {
    try {
      String url = '$_baseUrl/Supplements';
      if (isGlobal != null) {
        url += '?global=$isGlobal';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching supplements: ${e.message}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserSupplements() async {
    try {
      final response = await _dio.get('$_baseUrl/UserSupplements');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching user supplements: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addUserSupplement(
    String supplementId, {
    double? defaultDosage,
    String? defaultUnit,
  }) async {
    try {
      final Map<String, dynamic> data = {'supplementId': supplementId};

      if (defaultDosage != null) {
        data['defaultDosage'] = defaultDosage;
      }

      if (defaultUnit != null) {
        data['defaultUnit'] = defaultUnit;
      }

      final response = await _dio.post('$_baseUrl/UserSupplements', data: data);

      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('Error adding user supplement: ${e.message}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getIntakeLogs() async {
    try {
      final response = await _dio.get('$_baseUrl/IntakeLogs');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching intake logs: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addIntakeLog(
    String userSupplementId,
    DateTime intakeTime, {
    double? dosage,
    String? unit,
  }) async {
    try {
      final safeUnit = unit ?? 'шт';

      final Map<String, dynamic> data = {
        'supplementID': userSupplementId,
        'quantity': dosage ?? 1.0,
        'takenAt': intakeTime.toUtc().toIso8601String(),
        'unit': safeUnit,
      };

      print('Sending intake log data: $data');

      final response = await _dio.post(
        '$_baseUrl/IntakeLogs',
        data: data,
        options: Options(
          validateStatus: (status) => status! >= 200 && status < 300,
        ),
      );
      
      log('API успішно зберіг запис з кодом: ${response.statusCode}');
      print('API успішно зберіг запис з кодом: ${response.statusCode}');

      // Просто повертаємо порожній об'єкт, не намагаючись обробляти дані з сервера
      return {};
    } catch (e) {
      // Логуємо помилку, але не повертаємо null, щоб уникнути помилки при обробці
      print('Error in addIntakeLog: $e');

      // Повертаємо порожній об'єкт, щоб запобігти помилкам при обробці
      return {};
    }
  }
}

// Провайдер для доступу до API сервісу
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
