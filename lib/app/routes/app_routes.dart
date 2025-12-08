// lib/app/routes/app_routes.dart
import 'package:get/get.dart';
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/students_screen.dart';
import '../../screens/mark_attendance_screen.dart';
import '../../screens/attendance_history_screen.dart';
import '../../screens/reports_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/settings_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const students = '/students';
  static const markAttendance = '/mark-attendance';
  static const attendanceHistory = '/attendance-history';
  static const reports = '/reports';
  static const profile = '/profile';
  static const settings = '/settings';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: dashboard, page: () => DashboardScreen()),
    GetPage(name: students, page: () => StudentsScreen()),
    GetPage(name: markAttendance, page: () => MarkAttendanceScreen()),
    GetPage(name: attendanceHistory, page: () => AttendanceHistoryScreen()),
    GetPage(name: reports, page: () => ReportsScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: settings, page: () => SettingsScreen()),
  ];
}