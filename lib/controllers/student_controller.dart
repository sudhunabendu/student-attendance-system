// lib/controllers/student_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';

class StudentController extends GetxController {
  final isLoading = false.obs;
  final students = <StudentModel>[].obs;
  final filteredStudents = <StudentModel>[].obs;
  final searchController = TextEditingController();
  final selectedClass = 'All'.obs;
  final selectedSection = 'All'.obs;

  final classes = ['All', '10th', '11th', '12th'];
  final sections = ['All', 'A', 'B', 'C', 'D'];

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
    searchController.addListener(_filterStudents);
  }

  Future<void> fetchStudents() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    students.value = List.generate(
      30,
      (index) => StudentModel(
        id: 'STU${index + 1}',
        name: 'Student ${index + 1}',
        rollNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
        className: ['10th', '11th', '12th'][index % 3],
        section: ['A', 'B', 'C', 'D'][index % 4],
        parentPhone: '+1234567890',
      ),
    );
    
    filteredStudents.value = students;
    isLoading.value = false;
  }

  void _filterStudents() {
    String query = searchController.text.toLowerCase();
    
    filteredStudents.value = students.where((student) {
      bool matchesSearch = student.name.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query);
      bool matchesClass = selectedClass.value == 'All' ||
          student.className == selectedClass.value;
      bool matchesSection = selectedSection.value == 'All' ||
          student.section == selectedSection.value;
      
      return matchesSearch && matchesClass && matchesSection;
    }).toList();
  }

  void filterByClass(String className) {
    selectedClass.value = className;
    _filterStudents();
  }

  void filterBySection(String section) {
    selectedSection.value = section;
    _filterStudents();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}