import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _preferences;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<bool> setData<T>(String key, T data) async {
    try {
      String jsonData = json.encode(data);
      return await _preferences.setString(key, jsonData);
    } catch (e) {
      print('Error setting data: $e');
      return false;
    }
  }

  T? getData<T>(String key) {
    try {
      String? jsonData = _preferences.getString(key);
      if (jsonData != null) {
        return json.decode(jsonData) as T;
      }
    } catch (e) {
      print('Error getting data: $e');
    }
    return null;
  }

  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }
}
