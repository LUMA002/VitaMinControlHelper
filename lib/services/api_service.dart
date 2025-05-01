import 'dart:developer';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

class ApiService {
  final Dio _dio;
  final Ref _ref;
  // Важлива зміна змінної, не використовувати localhost!!!
  //final String _baseUrl = 'http://10.0.2.2:5241/api';

  // Make baseUrl accessible via a getter
  String get baseUrl {
    // Перевірка чи це емулятор (для Android)
    bool isEmulator = false;
    if (Platform.isAndroid) {
      isEmulator =
          Platform.operatingSystem == "android" &&
          Platform.environment.containsKey('ANDROID_EMU');
    }

    if (Platform.isWindows) {
      return 'http://localhost:5241/api';
    } else if (Platform.isAndroid) {
      if (isEmulator) {
        return 'http://10.0.2.2:5241/api'; // Для Android емулятора
      } else {
        return 'http://192.168.0.102:5241/api'; // Замініть на свою IP-адресу в локальній мережі
      }
    } else if (Platform.isIOS) {
      // Для iOS симулятора та фізичних пристроїв
      return 'http://192.168.0.104:5241/api'; // Замініть на свою IP-адресу в локальній мережі
    } /* else if (kIsWeb) {
      return 'http://localhost:5241/api';/*  веб теж під питанням через безпеку 
      (наразі проблема із використанням package fluttersecurestorage, не 
      підтримується поки для вебу і поки виглядає зайвим) */
    } */
    return 'http://localhost:5241/api'; // За замовчуванням
  }

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
        '$baseUrl/Auth/Login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      log('Login error: ${e.message}');
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

      final response = await _dio.post('$baseUrl/Auth/Register', data: data);

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      log('Register error: ${e.message}');
      return null;
    }
  }

  // Методи для доступу до даних
  Future<List<Map<String, dynamic>>> getSupplementTypes() async {
    try {
      final response = await _dio.get('$baseUrl/SupplementTypes');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      log('Error fetching supplement types: ${e.message}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSupplements({bool? isGlobal}) async {
    try {
      String url = '$baseUrl/Supplements';
      if (isGlobal != null) {
        url += '?global=$isGlobal';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      log('Error fetching supplements: ${e.message}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserSupplements() async {
    try {
      final response = await _dio.get('$baseUrl/UserSupplements');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      log('Error fetching user supplements: ${e.message}');
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

      final response = await _dio.post('$baseUrl/UserSupplements', data: data);

      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      log('Error adding user supplement: ${e.message}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getIntakeLogs() async {
    try {
      final response = await _dio.get('$baseUrl/IntakeLogs');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      log('Error fetching intake logs: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addIntakeLog(
    String userSupplementId,
    DateTime intakeTime, {
    double? dosage,
    String? unit,
    int quantity = 1, // Додано параметр quantity зі значенням за замовчуванням
  }) async {
    try {
      final safeUnit = unit ?? 'шт';

      final Map<String, dynamic> data = {
        'supplementID': userSupplementId,
        'quantity': quantity, // Змінено з dosage на quantity з типом int
        'dosage': dosage ?? 0.0, // Додано нове поле dosage
        'takenAt': intakeTime.toUtc().toIso8601String(),
        'unit': safeUnit,
      };

      log('Sending intake log data: $data');

      final response = await _dio.post(
        '$baseUrl/IntakeLogs',
        data: data,
        options: Options(
          validateStatus: (status) => status! >= 200 && status < 300,
        ),
      );

      log('API успішно зберіг запис з кодом: ${response.statusCode}');

      // Повертаємо фактичні дані з відповіді API
      if (response.data != null && response.data is Map<String, dynamic>) {
        log('Отримані дані з сервера: ${response.data}');
        return response.data;
      } else {
        // Якщо з якоїсь причини відповідь порожня, створюємо сумісний об'єкт
        log('Відповідь від сервера порожня або неправильного формату');
        return {};
      }
    } catch (e) {
      log('Error in addIntakeLog: $e');
      throw Exception('Failed to add intake log: $e');
    }
  }
}

// Провайдер для доступу до API сервісу
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
