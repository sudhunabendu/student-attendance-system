// // lib/services/storage_service.dart
// import 'package:shared_preferences/shared_preferences.dart';
// import '../app/utils/constants.dart';
// import '../models/user_model.dart';

// class StorageService {
//   // Singleton
//   static final StorageService _instance = StorageService._internal();
//   factory StorageService() => _instance;
//   StorageService._internal();

//   SharedPreferences? _prefs;

//   // Initialize
//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // Save Token
//   Future<bool> saveToken(String token) async {
//     return await _prefs?.setString(AppConstants.tokenKey, token) ?? false;
//   }

//   // Get Token
//   String? getToken() {
//     return _prefs?.getString(AppConstants.tokenKey);
//   }

//   // Remove Token
//   Future<bool> removeToken() async {
//     return await _prefs?.remove(AppConstants.tokenKey) ?? false;
//   }

//   // Save User
//   Future<bool> saveUser(UserModel user) async {
//     return await _prefs?.setString(AppConstants.userKey, user.toJsonString()) ?? false;
//   }

//   // Get User
//   UserModel? getUser() {
//     final userString = _prefs?.getString(AppConstants.userKey);
//     if (userString != null) {
//       return UserModel.fromJsonString(userString);
//     }
//     return null;
//   }

//   // Remove User
//   Future<bool> removeUser() async {
//     return await _prefs?.remove(AppConstants.userKey) ?? false;
//   }

//   // Save Login Status
//   Future<bool> setLoggedIn(bool value) async {
//     return await _prefs?.setBool(AppConstants.isLoggedInKey, value) ?? false;
//   }

//   // Check if Logged In
//   bool isLoggedIn() {
//     return _prefs?.getBool(AppConstants.isLoggedInKey) ?? false;
//   }

//   // Clear All Data
//   Future<bool> clearAll() async {
//     return await _prefs?.clear() ?? false;
//   }

//   // Save String
//   Future<bool> saveString(String key, String value) async {
//     return await _prefs?.setString(key, value) ?? false;
//   }

//   // Get String
//   String? getString(String key) {
//     return _prefs?.getString(key);
//   }

//   // Save Bool
//   Future<bool> saveBool(String key, bool value) async {
//     return await _prefs?.setBool(key, value) ?? false;
//   }

//   // Get Bool
//   bool? getBool(String key) {
//     return _prefs?.getBool(key);
//   }
// }


// lib/services/storage_service.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final GetStorage _box = GetStorage();

  // ══════════════════════════════════════════════════════════
  // STORAGE KEYS
  // ══════════════════════════════════════════════════════════
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberedMobile = 'remembered_mobile';

  // ══════════════════════════════════════════════════════════
  // USER
  // ══════════════════════════════════════════════════════════
  Future<bool> saveUser(UserModel user) async {
    try {
      await _box.write(_keyUser, jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  UserModel? getUser() {
    try {
      final userJson = _box.read<String>(_keyUser);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await _box.remove(_keyUser);
  }

  // ══════════════════════════════════════════════════════════
  // TOKEN
  // ══════════════════════════════════════════════════════════
  Future<bool> saveToken(String token) async {
    try {
      await _box.write(_keyToken, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  String? getToken() {
    return _box.read<String>(_keyToken);
  }

  Future<void> removeToken() async {
    await _box.remove(_keyToken);
  }

  // ══════════════════════════════════════════════════════════
  // LOGIN STATUS
  // ══════════════════════════════════════════════════════════
  Future<void> setLoggedIn(bool value) async {
    await _box.write(_keyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _box.read<bool>(_keyIsLoggedIn) ?? false;
  }

  // ══════════════════════════════════════════════════════════
  // REMEMBER ME
  // ══════════════════════════════════════════════════════════
  Future<void> saveRememberedMobile(String mobile) async {
    await _box.write(_keyRememberedMobile, mobile);
  }

  String? getRememberedMobile() {
    return _box.read<String>(_keyRememberedMobile);
  }

  Future<void> removeRememberedMobile() async {
    await _box.remove(_keyRememberedMobile);
  }

  // ══════════════════════════════════════════════════════════
  // CLEAR SESSION (for logout)
  // ══════════════════════════════════════════════════════════
  Future<void> clearSession() async {
    await removeUser();
    await removeToken();
    await setLoggedIn(false);
    // Note: We don't clear remembered mobile here
  }

  // ══════════════════════════════════════════════════════════
  // CLEAR ALL (for complete reset)
  // ══════════════════════════════════════════════════════════
  Future<void> clearAll() async {
    await _box.erase();
  }
}