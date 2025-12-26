import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme_controller.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();
  
  final _storage = GetStorage();

  // Theme Controller Reference
  final ThemeController themeController = Get.find<ThemeController>();

  // Observable Settings
  final RxBool notificationsEnabled = true.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool autoSync = true.obs;
  final RxString language = 'English'.obs;
  final RxString reminderTime = '8:00 AM'.obs;

  // Storage Keys
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _biometricKey = 'biometricEnabled';
  static const String _autoSyncKey = 'autoSync';
  static const String _languageKey = 'language';
  static const String _reminderTimeKey = 'reminderTime';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // ══════════════════════════════════════════════════════════
  // LOAD ALL SETTINGS
  // ══════════════════════════════════════════════════════════
  void _loadSettings() {
    notificationsEnabled.value = _storage.read(_notificationsKey) ?? true;
    biometricEnabled.value = _storage.read(_biometricKey) ?? false;
    autoSync.value = _storage.read(_autoSyncKey) ?? true;
    language.value = _storage.read(_languageKey) ?? 'English';
    reminderTime.value = _storage.read(_reminderTimeKey) ?? '8:00 AM';
  }

  // ══════════════════════════════════════════════════════════
  // DARK MODE
  // ══════════════════════════════════════════════════════════
  bool get isDarkMode => themeController.isDarkMode.value;

  void setDarkMode(bool value) {
    themeController.setDarkMode(value);
  }

  // ══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════════════════
  void setNotifications(bool value) {
    notificationsEnabled.value = value;
    _storage.write(_notificationsKey, value);
  }

  // ══════════════════════════════════════════════════════════
  // BIOMETRIC
  // ══════════════════════════════════════════════════════════
  void setBiometric(bool value) {
    biometricEnabled.value = value;
    _storage.write(_biometricKey, value);
  }

  // ══════════════════════════════════════════════════════════
  // AUTO SYNC
  // ══════════════════════════════════════════════════════════
  void setAutoSync(bool value) {
    autoSync.value = value;
    _storage.write(_autoSyncKey, value);
  }

  // ══════════════════════════════════════════════════════════
  // LANGUAGE
  // ══════════════════════════════════════════════════════════
  void setLanguage(String value) {
    language.value = value;
    _storage.write(_languageKey, value);
  }

  // ══════════════════════════════════════════════════════════
  // REMINDER TIME
  // ══════════════════════════════════════════════════════════
  void setReminderTime(String value) {
    reminderTime.value = value;
    _storage.write(_reminderTimeKey, value);
  }

  // ══════════════════════════════════════════════════════════
  // CLEAR CACHE
  // ══════════════════════════════════════════════════════════
  Future<void> clearCache() async {
    // Add your cache clearing logic here
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ══════════════════════════════════════════════════════════
  // RESET ALL SETTINGS
  // ══════════════════════════════════════════════════════════
  void resetAllSettings() {
    setDarkMode(false);
    setNotifications(true);
    setBiometric(false);
    setAutoSync(true);
    setLanguage('English');
    setReminderTime('8:00 AM');
  }
}