// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/notice_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<StudentController>(() => StudentController(), fenix: true);
    Get.lazyPut<AttendanceController>(() => AttendanceController(), fenix: true);
    Get.lazyPut<NoticeController>(() => NoticeController()); // ✅ Add this

  }
}