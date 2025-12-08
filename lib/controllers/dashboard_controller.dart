// lib/controllers/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;
  final totalStudents = 150.obs;
  final presentToday = 142.obs;
  final absentToday = 8.obs;
  final attendancePercentage = 94.7.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // Data is already set with mock values
  }
}
