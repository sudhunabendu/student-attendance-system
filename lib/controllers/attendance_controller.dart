// lib/controllers/attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';

class AttendanceController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectedDate = DateTime.now().obs;
  final students = <StudentModel>[].obs;
  final attendanceHistory = <AttendanceModel>[].obs;
  final selectedClass = '10th'.obs;
  final selectedSection = 'A'.obs;

  final classes = ['10th', '11th', '12th'];
  final sections = ['A', 'B', 'C', 'D'];

  @override
  void onInit() {
    super.onInit();
    fetchStudentsForAttendance();
    fetchAttendanceHistory();
  }

  Future<void> fetchStudentsForAttendance() async {
    isLoading.value = true;
    
    await Future.delayed(const Duration(seconds: 1));
    
    students.value = List.generate(
      25,
      (index) => StudentModel(
        id: 'STU${index + 1}',
        name: 'Student ${index + 1}',
        rollNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
        className: selectedClass.value,
        section: selectedSection.value,
        isPresent: false,
      ),
    );
    
    isLoading.value = false;
  }

  void toggleAttendance(int index) {
    students[index].isPresent = !students[index].isPresent;
    students.refresh();
  }

  void markAllPresent() {
    for (var student in students) {
      student.isPresent = true;
    }
    students.refresh();
  }

  void markAllAbsent() {
    for (var student in students) {
      student.isPresent = false;
    }
    students.refresh();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> saveAttendance() async {
    isSaving.value = true;
    
    await Future.delayed(const Duration(seconds: 2));
    
    int presentCount = students.where((s) => s.isPresent).length;
    int absentCount = students.length - presentCount;
    
    isSaving.value = false;
    
    Get.snackbar(
      'Success',
      'Attendance saved! Present: $presentCount, Absent: $absentCount',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    Get.back();
  }

  Future<void> fetchAttendanceHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // ✅ FIXED: Use AttendanceStatus enum instead of String
    final statuses = [
      AttendanceStatus.present,
      AttendanceStatus.absent,
      AttendanceStatus.late,
      AttendanceStatus.excused,
    ];
    
    attendanceHistory.value = List.generate(
      50,
      (index) => AttendanceModel(
        id: 'ATT${index + 1}',
        studentId: 'STU${(index % 30) + 1}',
        studentName: 'Student ${(index % 30) + 1}',
        date: DateTime.now()
            .subtract(Duration(days: index ~/ 30))
            .toString()
            .split(' ')[0],
        status: statuses[index % 4], // ✅ Now using enum
        markedBy: 'Teacher 1',
        markedAt: DateTime.now(),
      ),
    );
  }

  void changeClass(String newClass) {
    selectedClass.value = newClass;
    fetchStudentsForAttendance();
  }

  void changeSection(String newSection) {
    selectedSection.value = newSection;
    fetchStudentsForAttendance();
  }
}