// // lib/controllers/dashboard_controller.dart
// import 'package:get/get.dart';


// class DashboardController extends GetxController {
//   final selectedIndex = 0.obs;
//   final totalStudents = 150.obs;
//   final presentToday = 142.obs;
//   final absentToday = 8.obs;
//   final attendancePercentage = 94.7.obs;

//   void changeTab(int index) {
//     selectedIndex.value = index;
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchDashboardData();
//   }

//   Future<void> fetchDashboardData() async {
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 1));
//     // Data is already set with mock values
//   }
// }

// lib/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;
  final currentCarouselIndex = 0.obs;
  
  // Stats data
  final totalStudents = 150.obs;
  final presentToday = 142.obs;
  final absentToday = 8.obs;
  final attendancePercentage = 94.7.obs;

  // Carousel images - Add your image URLs here
  final List<Map<String, String>> carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      'title': 'Welcome to School',
      'subtitle': 'Excellence in Education',
    },
    {
      'image': 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800',
      'title': 'Smart Attendance',
      'subtitle': 'Track attendance efficiently',
    },
    {
      'image': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800',
      'title': 'Academic Success',
      'subtitle': 'Building future leaders',
    },
    {
      'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
      'title': 'Student Management',
      'subtitle': 'Simplified school operations',
    },
    {
      'image': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=800',
      'title': 'Digital Learning',
      'subtitle': 'Modern education solutions',
    },
  ];

  final CarouselSliderController carouselController = CarouselSliderController();

  void onCarouselPageChanged(int index, CarouselPageChangedReason reason) {
    currentCarouselIndex.value = index;
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
