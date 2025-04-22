import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base repository for interacting with SharedPreferences storage
class LocalStorageRepository {
  final SharedPreferences _prefs;

  LocalStorageRepository(this._prefs);

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save a list of strings
  Future<bool> saveStringList(String key, List<String> values) async {
    return await _prefs.setStringList(key, values);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Save a JSON serializable object
  Future<bool> saveObject<T>(String key, T object) async {
    if (object == null) {
      return false;
    }
    
    if (object is Map<String, dynamic>) {
      return await saveString(key, jsonEncode(object));
    } else {
      try {
        // This approach requires that the object has a toJson method
        final jsonString = jsonEncode(object);
        return await saveString(key, jsonString);
      } catch (e) {
        log('Error saving object to local storage: $e');
        return false;
      }
    }
  }

  /// Get a JSON serializable object
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonString = getString(key);
    if (jsonString == null) {
      return null;
    }
    
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(map);
    } catch (e) {
      log('Error retrieving object from local storage: $e');
      return null;
    }
  }

  /// Save a list of JSON serializable objects
  Future<bool> saveObjectList<T>(String key, List<T> objects) async {
    try {
      final jsonStringList = objects.map((obj) => jsonEncode(obj)).toList();
      return await saveStringList(key, jsonStringList);
    } catch (e) {
      log('Error saving object list to local storage: $e');
      return false;
    }
  }

  /// Get a list of JSON serializable objects
  List<T> getObjectList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonStringList = getStringList(key);
    if (jsonStringList == null) {
      return [];
    }
    
    try {
      return jsonStringList
          .map((jsonString) => fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      log('Error retrieving object list from local storage: $e');
      return [];
    }
  }
  
  /// Remove an item by key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  /// Clear all storage
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  throw UnimplementedError('Initialize this provider in your main.dart');
});