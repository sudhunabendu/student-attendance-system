// lib/app/utils/constants.dart
class ApiConstants {
  // Base URL - Change this to your API URL
  static const String baseUrl = 'https://student-attendance-system-backend-five.vercel.app/api';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';
  static const String students = '/students';
  static const String attendance = '/attendance';
  static const String markAttendance = '/auth/mark-attendance';
  static const String refreshToken = '/auth/refresh';
  static const String getAttendance = '/attendance';
  static const String getTodayAttendance = '/auth/get-today-attendance';
  static const String getAttendanceHistory = '/attendance/history';
  static const String getAttendanceStats = '/attendance/stats';
  static const String getStudentsByClass = '/attendance/students';
  static const String searchStudents = '/attendance/students';
  static const String getClasses = '/attendance/students';
  static const String getSections = '/attendance/students';
  static const String getStudentAttendance = '/attendance/students';

    // Student Endpoints
  static const String getStudents = '/students';
  static const String getStudentsForAttendance = '/students/for-attendance';
  // Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Auth Headers
  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class AppConstants {
  static const String appName = 'Attendance System';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}