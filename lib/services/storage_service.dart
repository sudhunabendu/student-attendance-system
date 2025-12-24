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