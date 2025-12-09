// lib/services/auth_service.dart
import '../app/utils/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Login
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        endpoint: ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.containsKey('error')) {
        return LoginResponse.error(response['error']);
      }

      final loginResponse = LoginResponse.fromJson(response);

      if (loginResponse.isSuccess && loginResponse.user != null) {
        // Save user data
        await _storageService.saveUser(loginResponse.user!);
        await _storageService.saveToken(loginResponse.user!.token);
        await _storageService.setLoggedIn(true);
      }

      return loginResponse;
    } catch (e) {
      return LoginResponse.error('Login failed: $e');
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _storageService.removeUser();
      await _storageService.removeToken();
      await _storageService.setLoggedIn(false);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check Auth Status
  bool isAuthenticated() {
    return _storageService.isLoggedIn() && _storageService.getToken() != null;
  }

  // Get Current User
  UserModel? getCurrentUser() {
    return _storageService.getUser();
  }

  // Get Token
  String? getToken() {
    return _storageService.getToken();
  }

  // Update User Profile
  Future<bool> updateProfile(UserModel user) async {
    return await _storageService.saveUser(user);
  }
}