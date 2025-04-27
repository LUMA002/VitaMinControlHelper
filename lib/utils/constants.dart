// This file contains global constants used throughout the application

// !!!!! Make a refuctor to use the constants in the app !!!!!

// API configuration
/* class ApiConfig {
  static const String baseUrl = 'http://localhost:5241/api';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Auth-related constants
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String usernameKey = 'username';
  static const String tokenExpirationKey = 'token_expiration';
}
 */
// Storage constants
/// Storage keys used in the app
class StorageKeys {
  /// Key for storing reminders
  static const String reminders = 'reminders';

  /// Key for storing user preferences
  static const String userPreferences = 'user_preferences';

  /// Key for storing last day check
  static const String lastDayCheck = 'last_day_check';
}
/* 
// Error messages
class ErrorMessages {
  static const String connectionError = 'Помилка з\'єднання з сервером. Перевірте підключення до інтернету.';
  static const String authError = 'Помилка авторизації. Спробуйте увійти знову.';
  static const String loadError = 'Не вдалося завантажити дані. Спробуйте знову.';
  static const String saveError = 'Не вдалося зберегти дані. Спробуйте знову.';
} */