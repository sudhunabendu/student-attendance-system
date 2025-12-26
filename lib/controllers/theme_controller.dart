import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  // Observable for dark mode
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  // ══════════════════════════════════════════════════════════
  // LOAD THEME FROM STORAGE
  // ══════════════════════════════════════════════════════════
  void _loadThemeFromStorage() {
    isDarkMode.value = _storage.read(_key) ?? false;
    _applyTheme();
  }

  // ══════════════════════════════════════════════════════════
  // TOGGLE THEME
  // ══════════════════════════════════════════════════════════
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveTheme();
    _applyTheme();
  }

  // ══════════════════════════════════════════════════════════
  // SET THEME
  // ══════════════════════════════════════════════════════════
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    _saveTheme();
    _applyTheme();
  }

  // ══════════════════════════════════════════════════════════
  // SAVE THEME TO STORAGE
  // ══════════════════════════════════════════════════════════
  void _saveTheme() {
    _storage.write(_key, isDarkMode.value);
  }

  // ══════════════════════════════════════════════════════════
  // APPLY THEME
  // ══════════════════════════════════════════════════════════
  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // ══════════════════════════════════════════════════════════
  // GET CURRENT THEME MODE
  // ══════════════════════════════════════════════════════════
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}