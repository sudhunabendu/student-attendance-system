// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../app/utils/constants.dart';
import '../models/user_model.dart';

class StorageService {
  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save Token
  Future<bool> saveToken(String token) async {
    return await _prefs?.setString(AppConstants.tokenKey, token) ?? false;
  }

  // Get Token
  String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  // Remove Token
  Future<bool> removeToken() async {
    return await _prefs?.remove(AppConstants.tokenKey) ?? false;
  }

  // Save User
  Future<bool> saveUser(UserModel user) async {
    return await _prefs?.setString(AppConstants.userKey, user.toJsonString()) ?? false;
  }

  // Get User
  UserModel? getUser() {
    final userString = _prefs?.getString(AppConstants.userKey);
    if (userString != null) {
      return UserModel.fromJsonString(userString);
    }
    return null;
  }

  // Remove User
  Future<bool> removeUser() async {
    return await _prefs?.remove(AppConstants.userKey) ?? false;
  }

  // Save Login Status
  Future<bool> setLoggedIn(bool value) async {
    return await _prefs?.setBool(AppConstants.isLoggedInKey, value) ?? false;
  }

  // Check if Logged In
  bool isLoggedIn() {
    return _prefs?.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Clear All Data
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  // Save String
  Future<bool> saveString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // Get String
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Save Bool
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // Get Bool
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
}