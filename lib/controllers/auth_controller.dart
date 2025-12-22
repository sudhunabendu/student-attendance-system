// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';

class AuthController extends GetxController {
  // ══════════════════════════════════════════════════════════
  // SERVICES
  // ══════════════════════════════════════════════════════════
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // ══════════════════════════════════════════════════════════
  // FORM CONTROLLERS
  // ══════════════════════════════════════════════════════════
  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  // ══════════════════════════════════════════════════════════
  // OBSERVABLES
  // ══════════════════════════════════════════════════════════
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final currentUser = Rxn<UserModel>();

  // ══════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    _loadRememberedCredentials();
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════
  // CHECK LOGIN STATUS
  // ══════════════════════════════════════════════════════════
  Future<void> _checkLoginStatus() async {
    final isUserLoggedIn = _storageService.isLoggedIn();
    final token = _storageService.getToken();
    final user = _storageService.getUser();

    if (isUserLoggedIn && token != null && user != null) {
      isLoggedIn.value = true;
      currentUser.value = user;
      
      // Navigate to dashboard
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed(AppRoutes.dashboard);
      });
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD REMEMBERED CREDENTIALS
  // ══════════════════════════════════════════════════════════
  void _loadRememberedCredentials() {
    final rememberedMobile = _storageService.getRememberedMobile();
    if (rememberedMobile != null && rememberedMobile.isNotEmpty) {
      mobileController.text = rememberedMobile;
      rememberMe.value = true;
    }
  }

  // ══════════════════════════════════════════════════════════
  // VALIDATORS
  // ══════════════════════════════════════════════════════════
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════
  // TOGGLE FUNCTIONS
  // ══════════════════════════════════════════════════════════
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // ══════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════
  Future<void> login() async {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final mobileNumber = mobileController.text.trim();
      final password = passwordController.text;

      debugPrint('📤 Attempting login with mobile: $mobileNumber');

      final response = await _authService.login(
        mobileNumber: mobileNumber,
        password: password,
      );

      debugPrint('📥 Login response: ${response.isSuccess}');

      if (response.isSuccess && response.user != null) {
        // ✅ Save user data to storage ONLY after successful login
        await _saveUserSession(response.user!, response.user!.token);

        // Update observables
        currentUser.value = response.user;
        isLoggedIn.value = true;

        // Handle remember me
        if (rememberMe.value) {
          await _storageService.saveRememberedMobile(mobileNumber);
        } else {
          await _storageService.removeRememberedMobile();
          passwordController.clear();
        }

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);

        // Show success message
        _showSuccessSnackbar(
          'Welcome Back!',
          'Hello ${response.user?.firstName ?? 'User'}!',
        );
      } else {
        // Show error message
        _showErrorSnackbar(
          'Login Failed',
          response.error ?? response.response ?? 'Invalid credentials',
        );
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _showErrorSnackbar(
        'Error',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // SAVE USER SESSION
  // ══════════════════════════════════════════════════════════
  Future<void> _saveUserSession(UserModel user, String? token) async {
    await _storageService.saveUser(user);
    if (token != null) {
      await _storageService.saveToken(token);
    }
    await _storageService.setLoggedIn(true);
    
    debugPrint('✓ User session saved');
  }

  // ══════════════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Clear storage
      await _storageService.clearSession();

      // Reset observables
      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear password field (keep mobile if remember me is on)
      passwordController.clear();
      if (!rememberMe.value) {
        mobileController.clear();
      }

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.login);

      _showSuccessSnackbar('Logged Out', 'You have been logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _showErrorSnackbar('Error', 'Failed to logout. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════
  // FORCE LOGOUT (for session expiry)
  // ══════════════════════════════════════════════════════════
  Future<void> forceLogout({String? message}) async {
    await _storageService.clearSession();

    currentUser.value = null;
    isLoggedIn.value = false;
    passwordController.clear();

    Get.offAllNamed(AppRoutes.login);

    if (message != null) {
      _showErrorSnackbar('Session Expired', message);
    }
  }

  // ══════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ══════════════════════════════════════════════════════════
  void _showSuccessSnackbar(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }

  void _showErrorSnackbar(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}