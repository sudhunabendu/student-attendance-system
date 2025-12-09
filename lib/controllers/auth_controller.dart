// lib/controllers/auth_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../app/routes/app_routes.dart';
// import '../models/user_model.dart';

// class AuthController extends GetxController {
//   final isLoading = false.obs;
//   final isLoggedIn = false.obs;
//   final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final obscurePassword = true.obs;

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   Future<void> login() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please fill all fields',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     isLoading.value = true;
    
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));
    
//     // Mock user data
//     currentUser.value = UserModel(
//       id: '1',
//       name: 'John Doe',
//       email: emailController.text,
//       role: 'Teacher',
//       department: 'Computer Science',
//     );
    
//     isLoading.value = false;
//     isLoggedIn.value = true;
    
//     Get.offAllNamed(AppRoutes.dashboard);
    
//     Get.snackbar(
//       'Success',
//       'Welcome back, ${currentUser.value?.name}!',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void logout() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               currentUser.value = null;
//               isLoggedIn.value = false;
//               emailController.clear();
//               passwordController.clear();
//               Get.offAllNamed(AppRoutes.login);
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }

// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  // Observables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form Key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    await _storageService.init();
    
    if (_authService.isAuthenticated()) {
      currentUser.value = _authService.getCurrentUser();
      isLoggedIn.value = true;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Login
  Future<void> login() async {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.isSuccess && response.user != null) {
        currentUser.value = response.user;
        isLoggedIn.value = true;

        // Clear password field for security
        if (!rememberMe.value) {
          passwordController.clear();
        }

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);

        // Show success message
        _showSuccessSnackbar(
          'Welcome Back!',
          'Hello ${currentUser.value?.firstName ?? 'User'}!',
        );
      } else {
        // Show error message
        _showErrorSnackbar(
          'Login Failed',
          response.error ?? response.response ?? 'Something went wrong',
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Error',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Perform logout
  Future<void> _performLogout() async {
    // Show loading
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await _authService.logout();

    currentUser.value = null;
    isLoggedIn.value = false;
    
    if (!rememberMe.value) {
      emailController.clear();
    }
    passwordController.clear();

    Get.back(); // Close loading dialog
    Get.offAllNamed(AppRoutes.login);

    _showSuccessSnackbar(
      'Logged Out',
      'You have been logged out successfully.',
    );
  }

  // Success Snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Error Snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  // Getters
  String? get token => currentUser.value?.token;
  String get userName => currentUser.value?.name ?? 'User';
  String get userEmail => currentUser.value?.email ?? '';
  String get userInitials => currentUser.value?.initials ?? 'U';
  String get userFirstName => currentUser.value?.firstName ?? 'User';

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}