// // lib/services/auth_service.dart
// import '../app/utils/constants.dart';
// import '../models/user_model.dart';
// import 'api_service.dart';
// import 'storage_service.dart';

// class AuthService {
//   final ApiService _apiService = ApiService();
//   final StorageService _storageService = StorageService();

//   // Login
//   Future<LoginResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         endpoint: ApiConstants.login,
//         body: {
//           'email': email,
//           'password': password,
//         },
//       );

//       if (response.containsKey('error')) {
//         return LoginResponse.error(response['error']);
//       }

//       final loginResponse = LoginResponse.fromJson(response);

//       if (loginResponse.isSuccess && loginResponse.user != null) {
//         // Save user data
//         await _storageService.saveUser(loginResponse.user!);
//         await _storageService.saveToken(loginResponse.user!.token);
//         await _storageService.setLoggedIn(true);
//       }

//       return loginResponse;
//     } catch (e) {
//       return LoginResponse.error('Login failed: $e');
//     }
//   }

//   // Logout
//   Future<bool> logout() async {
//     try {
//       await _storageService.removeUser();
//       await _storageService.removeToken();
//       await _storageService.setLoggedIn(false);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Check Auth Status
//   bool isAuthenticated() {
//     return _storageService.isLoggedIn() && _storageService.getToken() != null;
//   }

//   // Get Current User
//   UserModel? getCurrentUser() {
//     return _storageService.getUser();
//   }

//   // Get Token
//   String? getToken() {
//     return _storageService.getToken();
//   }

//   // Update User Profile
//   Future<bool> updateProfile(UserModel user) async {
//     return await _storageService.saveUser(user);
//   }
// }

// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../app/utils/constants.dart';
import '../models/user_model.dart';

class AuthService {
  // ══════════════════════════════════════════════════════════
  // LOGIN WITH MOBILE NUMBER & PASSWORD
  // ══════════════════════════════════════════════════════════
  Future<LoginResponse> login({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

      final body = {'mobile_number': mobileNumber, 'password': password};

      debugPrint('📤 Login URL: $url');
      debugPrint('📤 Login Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📥 Login Status Code: ${response.statusCode}');

      final data = jsonDecode(response.body);
      debugPrint('📥 Login Response: $data');

      // Handle different response formats
      if (response.statusCode == 200 || data['res_code'] == 200) {
        return LoginResponse.fromJson(data);
      } else {
        return LoginResponse.error(
          data['message'] ?? data['response'] ?? 'Login failed',
        );
      }
    } catch (e) {
      debugPrint('❌ Login Error: $e');
      return LoginResponse.error('Network error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // VERIFY TOKEN (optional - for session validation)
  // ══════════════════════════════════════════════════════════
  //   Future<bool> verifyToken(String token) async {
  //     try {
  //       final url = Uri.parse(
  //         '${ApiConstants.baseUrl}${ApiConstants.verifyToken}',
  //       );

  //       final response = await http.get(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Accept': 'application/json',
  //           'Authorization': 'Bearer $token',
  //         },
  //       );

  //       final data = jsonDecode(response.body);
  //       return response.statusCode == 200 &&
  //           (data['success'] == true || data['res_code'] == 200);
  //     } catch (e) {
  //       debugPrint('❌ Token verification error: $e');
  //       return false;
  //     }
  //   }
  // }

  // ══════════════════════════════════════════════════════════
  // LOGIN RESPONSE MODEL
  // ══════════════════════════════════════════════════════════
  // class LoginResponse {
  //   final bool isSuccess;
  //   final String? response;
  //   final String? error;
  //   final UserModel? user;

  //   LoginResponse({
  //     required this.isSuccess,
  //     this.response,
  //     this.error,
  //     this.user,
  //   });

  //   factory LoginResponse.fromJson(Map<String, dynamic> json) {
  //     final bool success =
  //         json['res_code'] == 200 ||
  //         json['success'] == true ||
  //         json['status'] == 'success';

  //     UserModel? user;
  //     if (success && json['data'] != null) {
  //       user = UserModel.fromJson(json['data']);
  //     }

  //     return LoginResponse(
  //       isSuccess: success,
  //       response: json['response'] ?? json['message'],
  //       error: success ? null : (json['message'] ?? json['response']),
  //       user: user,
  //     );
  //   }

  //   factory LoginResponse.error(String message) {
  //     return LoginResponse(isSuccess: false, error: message, user: null);
  //   }
  // }
}
