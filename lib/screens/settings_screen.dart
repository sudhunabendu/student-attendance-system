import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize Settings Controller
    final controller = Get.put(SettingsController());
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ══════════════════════════════════════════════════════════
          // APPEARANCE SECTION
          // ══════════════════════════════════════════════════════════
          _buildSectionHeader(context, 'Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // ✅ Dark Mode Toggle
                Obx(() => SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Switch between light and dark theme'),
                      value: themeController.isDarkMode.value,
                      onChanged: (value) => themeController.setDarkMode(value),
                      secondary: Icon(
                        themeController.isDarkMode.value
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    )),
                const Divider(height: 1),
                // Language
                Obx(() => ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(controller.language.value),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLanguageDialog(context, controller),
                    )),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // NOTIFICATIONS SECTION
          // ══════════════════════════════════════════════════════════
          _buildSectionHeader(context, 'Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Receive attendance reminders'),
                      value: controller.notificationsEnabled.value,
                      onChanged: (value) => controller.setNotifications(value),
                      secondary: const Icon(Icons.notifications),
                    )),
                const Divider(height: 1),
                Obx(() => ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Reminder Time'),
                      subtitle: Text(controller.reminderTime.value),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showTimePickerDialog(context, controller),
                    )),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // SECURITY SECTION
          // ══════════════════════════════════════════════════════════
          _buildSectionHeader(context, 'Security'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Biometric Login'),
                      subtitle: const Text('Use fingerprint to login'),
                      value: controller.biometricEnabled.value,
                      onChanged: (value) => controller.setBiometric(value),
                      secondary: const Icon(Icons.fingerprint),
                    )),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to change password screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Disabled'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to 2FA screen
                  },
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // DATA & SYNC SECTION
          // ══════════════════════════════════════════════════════════
          _buildSectionHeader(context, 'Data & Sync'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Auto Sync'),
                      subtitle: const Text('Automatically sync attendance data'),
                      value: controller.autoSync.value,
                      onChanged: (value) => controller.setAutoSync(value),
                      secondary: const Icon(Icons.sync),
                    )),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Export Data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Export data functionality
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearCacheDialog(context, controller),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // ABOUT SECTION
          // ══════════════════════════════════════════════════════════
          _buildSectionHeader(context, 'About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // RESET SETTINGS
          // ══════════════════════════════════════════════════════════
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetSettingsDialog(context, controller),
              icon: const Icon(Icons.restore, color: Colors.red),
              label: const Text(
                'Reset All Settings',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // LANGUAGE DIALOG
  // ══════════════════════════════════════════════════════════
  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    final languages = ['English', 'Hindi', 'Spanish', 'French', 'German'];

    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return Obx(() => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: controller.language.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguage(value);
                      Get.back();
                    }
                  },
                ));
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TIME PICKER DIALOG
  // ══════════════════════════════════════════════════════════
  void _showTimePickerDialog(
      BuildContext context, SettingsController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      controller.setReminderTime('$hour:$minute $period');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CLEAR CACHE DIALOG
  // ══════════════════════════════════════════════════════════
  void _showClearCacheDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'Are you sure you want to clear the cache? This will free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              await controller.clearCache();

              Get.back(); // Close loading

              Get.snackbar(
                'Success',
                'Cache cleared successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // RESET SETTINGS DIALOG
  // ══════════════════════════════════════════════════════════
  void _showResetSettingsDialog(
      BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetAllSettings();
              Get.back();
              Get.snackbar(
                'Success',
                'All settings have been reset to default!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}