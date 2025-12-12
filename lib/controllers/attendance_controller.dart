// lib/controllers/attendance_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/student_model.dart';
// import '../models/attendance_model.dart';

// class AttendanceController extends GetxController {
//   final isLoading = false.obs;
//   final isSaving = false.obs;
//   final selectedDate = DateTime.now().obs;
//   final students = <StudentModel>[].obs;
//   final attendanceHistory = <AttendanceModel>[].obs;
//   final selectedClass = '10th'.obs;
//   final selectedSection = 'A'.obs;

//   final classes = ['10th', '11th', '12th'];
//   final sections = ['A', 'B', 'C', 'D'];

//   @override
//   void onInit() {
//     super.onInit();
//     fetchStudentsForAttendance();
//     fetchAttendanceHistory();
//   }

//   Future<void> fetchStudentsForAttendance() async {
//     isLoading.value = true;
    
//     await Future.delayed(const Duration(seconds: 1));
    
//     students.value = List.generate(
//       25,
//       (index) => StudentModel(
//         id: 'STU${index + 1}',
//         name: 'Student ${index + 1}',
//         rollNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
//         className: selectedClass.value,
//         section: selectedSection.value,
//         isPresent: false,
//       ),
//     );
    
//     isLoading.value = false;
//   }

//   void toggleAttendance(int index) {
//     students[index].isPresent = !students[index].isPresent;
//     students.refresh();
//   }

//   void markAllPresent() {
//     for (var student in students) {
//       student.isPresent = true;
//     }
//     students.refresh();
//   }

//   void markAllAbsent() {
//     for (var student in students) {
//       student.isPresent = false;
//     }
//     students.refresh();
//   }

//   Future<void> selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       selectedDate.value = picked;
//     }
//   }

//   Future<void> saveAttendance() async {
//     isSaving.value = true;
    
//     await Future.delayed(const Duration(seconds: 2));
    
//     int presentCount = students.where((s) => s.isPresent).length;
//     int absentCount = students.length - presentCount;
    
//     isSaving.value = false;
    
//     Get.snackbar(
//       'Success',
//       'Attendance saved! Present: $presentCount, Absent: $absentCount',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     );
    
//     Get.back();
//   }

//   Future<void> fetchAttendanceHistory() async {
//     await Future.delayed(const Duration(seconds: 1));
    
//     // ✅ FIXED: Use AttendanceStatus enum instead of String
//     final statuses = [
//       AttendanceStatus.present,
//       AttendanceStatus.absent,
//       AttendanceStatus.late,
//       AttendanceStatus.excused,
//     ];
    
//     attendanceHistory.value = List.generate(
//       50,
//       (index) => AttendanceModel(
//         id: 'ATT${index + 1}',
//         studentId: 'STU${(index % 30) + 1}',
//         studentName: 'Student ${(index % 30) + 1}',
//         date: DateTime.now()
//             .subtract(Duration(days: index ~/ 30))
//             .toString()
//             .split(' ')[0],
//         status: statuses[index % 4], // ✅ Now using enum
//         markedBy: 'Teacher 1',
//         markedAt: DateTime.now(),
//       ),
//     );
//   }

//   void changeClass(String newClass) {
//     selectedClass.value = newClass;
//     fetchStudentsForAttendance();
//   }

//   void changeSection(String newSection) {
//     selectedSection.value = newSection;
//     fetchStudentsForAttendance();
//   }
// }

// lib/controllers/attendance_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../services/storage_service.dart';

class AttendanceController extends GetxController {
  // ══════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ══════════════════════════════════════════════════════════
  final StorageService _storageService = StorageService();

  // ══════════════════════════════════════════════════════════
  // OBSERVABLES - Loading States
  // ══════════════════════════════════════════════════════════
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isLoadingHistory = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // ══════════════════════════════════════════════════════════
  // OBSERVABLES - Data
  // ══════════════════════════════════════════════════════════
  final selectedDate = DateTime.now().obs;
  final students = <StudentModel>[].obs;
  final filteredStudents = <StudentModel>[].obs;
  final attendanceHistory = <AttendanceModel>[].obs;

  // ══════════════════════════════════════════════════════════
  // OBSERVABLES - Filters
  // ══════════════════════════════════════════════════════════
  final selectedClass = '10th'.obs;
  final selectedSection = 'A'.obs;
  final selectedClassId = ''.obs;
  final searchQuery = ''.obs;

  // ══════════════════════════════════════════════════════════
  // OBSERVABLES - Progress Tracking
  // ══════════════════════════════════════════════════════════
  final currentProgress = 0.obs;
  final totalToMark = 0.obs;
  final failedStudents = <StudentModel>[].obs;
  final successCount = 0.obs;
  final alreadyMarkedCount = 0.obs;

  // ══════════════════════════════════════════════════════════
  // OPTIONS
  // ══════════════════════════════════════════════════════════
  final classes = ['10th', '11th', '12th'];
  final sections = ['A', 'B', 'C', 'D'];

  // ══════════════════════════════════════════════════════════
  // CONTROLLERS
  // ══════════════════════════════════════════════════════════
  final searchController = TextEditingController();
  Timer? _debounceTimer;

  // ══════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════
  String? get _authToken => _storageService.getToken();
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  int get presentCount => students.where((s) => s.isPresent).length;
  int get absentCount => students.length - presentCount;
  int get totalCount => students.length;

  double get attendancePercentage =>
      students.isEmpty ? 0 : (presentCount / students.length) * 100;

  String get progressText => '${currentProgress.value}/${totalToMark.value}';

  double get progressPercentage =>
      totalToMark.value > 0 ? currentProgress.value / totalToMark.value : 0;

  bool get hasFailedStudents => failedStudents.isNotEmpty;

  String get formattedSelectedDate {
    final date = selectedDate.value;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get selectedDateString {
    final date = selectedDate.value;
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ══════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> _initController() async {
    searchController.addListener(_onSearchChanged);
    await fetchStudentsForAttendance();
    fetchAttendanceHistory();
  }

  // ══════════════════════════════════════════════════════════
  // FETCH STUDENTS FOR ATTENDANCE
  // ══════════════════════════════════════════════════════════
  Future<void> fetchStudentsForAttendance() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      if (isAuthenticated && selectedClassId.value.isNotEmpty) {
        final result = await AttendanceService.getStudentsForAttendance(
          token: _authToken!,
          classId: selectedClassId.value,
          section: selectedSection.value,
          date: selectedDateString,
        );

        if (result['success'] == true) {
          students.value = result['students'] ?? [];

          // Mark already marked students
          final List<dynamic> alreadyMarked = result['alreadyMarked'] ?? [];
          for (var studentId in alreadyMarked) {
            final index = students.indexWhere((s) => s.id == studentId);
            if (index != -1) {
              students[index].isPresent = true;
              students[index].isMarkedOnServer = true;
            }
          }
          students.refresh();
        } else {
          _loadMockStudents();
        }
      } else {
        _loadMockStudents();
      }

      _applyFilters();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: $e';
      _showErrorSnackbar('Failed to fetch students: $e');
      _loadMockStudents();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockStudents() {
    students.value = List.generate(
      25,
      (index) => StudentModel(
        id: 'STU${index + 1}',
        firstName: 'Student',
        lastName: '${index + 1}',
        rollNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
        className: selectedClass.value,
        section: selectedSection.value,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FETCH ATTENDANCE HISTORY
  // ══════════════════════════════════════════════════════════
  Future<void> fetchAttendanceHistory({
    String? startDate,
    String? endDate,
    String? studentId,
  }) async {
    isLoadingHistory.value = true;

    try {
      if (isAuthenticated) {
        final result = await AttendanceService.getAttendanceHistory(
          token: _authToken!,
          startDate: startDate,
          endDate: endDate,
          classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
          section: selectedSection.value,
          studentId: studentId,
        );

        if (result['success'] == true) {
          attendanceHistory.value = result['attendance'] ?? [];
        } else {
          _loadMockAttendanceHistory();
        }
      } else {
        _loadMockAttendanceHistory();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to fetch history: $e');
      _loadMockAttendanceHistory();
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void _loadMockAttendanceHistory() {
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
        studentRollNumber: '2024${((index % 30) + 1).toString().padLeft(3, '0')}',
        studentClassName: ['10th', '11th', '12th'][index % 3],
        studentSection: ['A', 'B', 'C', 'D'][index % 4],
        date: DateTime.now().subtract(Duration(days: index ~/ 5)),
        status: statuses[index % 4],
        scannedBy: 'teacher_1',
        scannedByName: 'Teacher 1',
        createdAt: DateTime.now().subtract(Duration(days: index ~/ 5)),
        checkInTime: DateTime.now().subtract(Duration(days: index ~/ 5)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TOGGLE ATTENDANCE (LOCAL)
  // ══════════════════════════════════════════════════════════
  void toggleAttendance(int index) {
    if (index < 0 || index >= students.length) return;

    if (students[index].isMarkedOnServer) {
      _showWarningSnackbar('Attendance already marked on server');
      return;
    }

    students[index].isPresent = !students[index].isPresent;
    students.refresh();
    _applyFilters();
  }

  void toggleAttendanceById(String studentId) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      toggleAttendance(index);
    }
  }

  void markAllPresent() {
    for (var student in students) {
      if (!student.isMarkedOnServer) {
        student.isPresent = true;
      }
    }
    students.refresh();
    _applyFilters();
  }

  void markAllAbsent() {
    for (var student in students) {
      if (!student.isMarkedOnServer) {
        student.isPresent = false;
      }
    }
    students.refresh();
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // MARK SINGLE STUDENT ATTENDANCE (API)
  // ══════════════════════════════════════════════════════════
  Future<bool> markSingleStudentAttendance(String studentId) async {
    if (!isAuthenticated) {
      _showErrorSnackbar('Authentication required. Please login again.');
      return false;
    }

    try {
      final result = await AttendanceService.markAttendance(
        token: _authToken!,
        studentId: studentId,
        classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
      );

      if (result['success'] == true) {
        if (result['alreadyMarked'] == true) {
          _showInfoSnackbar(result['message'] ?? 'Already marked');
        } else {
          _showSuccessSnackbar(result['message'] ?? 'Attendance marked');
        }
        return true;
      } else {
        _showErrorSnackbar(result['message'] ?? 'Failed to mark attendance');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Network error: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // MARK ATTENDANCE FOR STUDENT WITH UI UPDATE
  // ══════════════════════════════════════════════════════════
  Future<void> markAttendanceForStudent(int index) async {
    if (index < 0 || index >= students.length) return;

    final student = students[index];

    if (student.isMarkedOnServer) {
      _showWarningSnackbar('Already marked for ${student.name}');
      return;
    }

    student.isLoading = true;
    students.refresh();

    final success = await markSingleStudentAttendance(student.id);

    if (success) {
      student.isPresent = true;
      student.isMarkedOnServer = true;
    }

    student.isLoading = false;
    students.refresh();
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // SAVE ALL ATTENDANCE
  // ══════════════════════════════════════════════════════════
  // Future<void> saveAttendance() async {
  //   if (!isAuthenticated) {
  //     _showErrorSnackbar('Authentication required. Please login again.');
  //     return;
  //   }

  //   final studentsToMark = students
  //       .where((s) => s.isPresent && !s.isMarkedOnServer)
  //       .toList();

  //   if (studentsToMark.isEmpty) {
  //     _showWarningSnackbar('No new attendance to save');
  //     return;
  //   }

  //   isSaving.value = true;
  //   currentProgress.value = 0;
  //   totalToMark.value = studentsToMark.length;
  //   failedStudents.clear();
  //   successCount.value = 0;
  //   alreadyMarkedCount.value = 0;

  //   for (int i = 0; i < studentsToMark.length; i++) {
  //     final student = studentsToMark[i];
  //     currentProgress.value = i + 1;

  //     try {
  //       final result = await AttendanceService.markAttendance(
  //         token: _authToken!,
  //         studentId: student.id,
  //         classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
  //       );

  //       if (result['success'] == true) {
  //         if (result['alreadyMarked'] == true) {
  //           alreadyMarkedCount.value++;
  //         } else {
  //           successCount.value++;
  //         }
  //         student.isMarkedOnServer = true;
  //       } else {
  //         failedStudents.add(student);
  //       }
  //     } catch (e) {
  //       failedStudents.add(student);
  //       debugPrint('Error marking attendance for ${student.id}: $e');
  //     }

  //     await Future.delayed(const Duration(milliseconds: 100));
  //   }

  //   students.refresh();
  //   isSaving.value = false;

  //   _showResultSummary();

  //   if (failedStudents.isEmpty) {
  //     await Future.delayed(const Duration(seconds: 2));
  //     Get.back(result: true);
  //   }
  // }

  Future<void> saveAttendance() async {
  if (!isAuthenticated) {
    _showErrorSnackbar('Authentication required. Please login again.');
    return;
  }

  final studentsToMark = students
      .where((s) => s.isPresent && !s.isMarkedOnServer)
      .toList();

  if (studentsToMark.isEmpty) {
    _showWarningSnackbar('No new attendance to save');
    return;
  }

  isSaving.value = true;
  currentProgress.value = 0;
  totalToMark.value = studentsToMark.length;
  failedStudents.clear();
  successCount.value = 0;
  alreadyMarkedCount.value = 0;

  final List<Map<String, dynamic>> results = [];

  for (int i = 0; i < studentsToMark.length; i++) {
    final student = studentsToMark[i];
    currentProgress.value = i + 1;

    try {
      final result = await AttendanceService.markAttendance(
        token: _authToken!,
        studentId: student.id,
        classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
      );

      debugPrint('Response for ${student.name}: $result');

      if (result['success'] == true) {
        // Get actual status from response
        final markedStatus = result['status'] ?? 
                             result['data']?['status'] ?? 
                             'present';
        
        // Check if already marked
        if (result['alreadyMarked'] == true) {
          alreadyMarkedCount.value++;
        } else {
          successCount.value++;
        }
        
        // Update student with server response
        student.isMarkedOnServer = true;
        student.attendanceStatus = markedStatus;
        
        results.add({
          'student': student.name,
          'status': markedStatus,
          'success': true,
        });
      } else {
        failedStudents.add(student);
        results.add({
          'student': student.name,
          'error': result['message'],
          'success': false,
        });
      }
    } catch (e) {
      failedStudents.add(student);
      results.add({
        'student': student.name,
        'error': e.toString(),
        'success': false,
      });
      debugPrint('Error marking attendance for ${student.id}: $e');
    }

    await Future.delayed(const Duration(milliseconds: 100));
  }

  students.refresh();
  isSaving.value = false;

  // Show detailed result
  _showResultSummaryWithDetails(results);

  if (failedStudents.isEmpty) {
    await Future.delayed(const Duration(seconds: 2));
    Get.back(result: true);
  }
}

void _showResultSummaryWithDetails(List<Map<String, dynamic>> results) {
  final presentCount = results.where((r) => r['status'] == 'present').length;
  final lateCount = results.where((r) => r['status'] == 'late').length;
  final failedCount = results.where((r) => r['success'] == false).length;

  final message = StringBuffer();

  if (presentCount > 0) message.writeln('✅ Present: $presentCount');
  if (lateCount > 0) message.writeln('⏰ Late: $lateCount');
  if (alreadyMarkedCount.value > 0) message.writeln('📋 Already marked: ${alreadyMarkedCount.value}');
  if (failedCount > 0) message.writeln('❌ Failed: $failedCount');
  message.write('🚫 Absent: $absentCount');

  Get.snackbar(
    'Attendance Summary',
    message.toString(),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: failedCount > 0 ? Colors.orange : 
                     lateCount > 0 ? Colors.orange : Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 5),
    margin: const EdgeInsets.all(10),
  );
}

  // ══════════════════════════════════════════════════════════
  // RETRY FAILED ATTENDANCE
  // ══════════════════════════════════════════════════════════
  Future<void> retryFailedAttendance() async {
    if (failedStudents.isEmpty) return;

    if (!isAuthenticated) {
      _showErrorSnackbar('Authentication required.');
      return;
    }

    isSaving.value = true;
    final studentsToRetry = List<StudentModel>.from(failedStudents);
    failedStudents.clear();
    currentProgress.value = 0;
    totalToMark.value = studentsToRetry.length;

    int retrySuccess = 0;

    for (int i = 0; i < studentsToRetry.length; i++) {
      final student = studentsToRetry[i];
      currentProgress.value = i + 1;

      try {
        final result = await AttendanceService.markAttendance(
          token: _authToken!,
          studentId: student.id,
          classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
        );

        if (result['success'] == true) {
          retrySuccess++;
          student.isMarkedOnServer = true;
          successCount.value++;
        } else {
          failedStudents.add(student);
        }
      } catch (e) {
        failedStudents.add(student);
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    students.refresh();
    isSaving.value = false;

    if (failedStudents.isEmpty) {
      _showSuccessSnackbar('All retry succeeded!');
      await Future.delayed(const Duration(seconds: 2));
      Get.back(result: true);
    } else {
      _showWarningSnackbar(
        '$retrySuccess succeeded, ${failedStudents.length} failed',
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH & FILTER
  // ══════════════════════════════════════════════════════════
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<StudentModel> result = List.from(students);

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((student) {
        return student.name.toLowerCase().contains(query) ||
            (student.rollNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filteredStudents.value = result;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // CLASS & SECTION CHANGES
  // ══════════════════════════════════════════════════════════
  void changeClass(String newClass) {
    selectedClass.value = newClass;
    fetchStudentsForAttendance();
  }

  void changeSection(String newSection) {
    selectedSection.value = newSection;
    fetchStudentsForAttendance();
  }

  // ══════════════════════════════════════════════════════════
  // DATE PICKER
  // ══════════════════════════════════════════════════════════
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      await fetchStudentsForAttendance();
    }
  }

  // ══════════════════════════════════════════════════════════
  // REFRESH
  // ══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await fetchStudentsForAttendance();
  }

  // ══════════════════════════════════════════════════════════
  // SNACKBARS
  // ══════════════════════════════════════════════════════════
  void _showSuccessSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
    }
  }

  void _showWarningSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Warning',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
    }
  }

  void _showInfoSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Info',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
    }
  }

  void _showResultSummary() {
    final message = StringBuffer();

    if (successCount.value > 0) {
      message.writeln('✅ Marked: ${successCount.value}');
    }
    if (alreadyMarkedCount.value > 0) {
      message.writeln('📋 Already: ${alreadyMarkedCount.value}');
    }
    if (failedStudents.isNotEmpty) {
      message.writeln('❌ Failed: ${failedStudents.length}');
    }
    message.write('🚫 Absent: $absentCount');

    Get.snackbar(
      'Summary',
      message.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: failedStudents.isNotEmpty ? Colors.orange : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(10),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATISTICS
  // ══════════════════════════════════════════════════════════
  Map<String, int> getAttendanceSummary() {
    return {
      'total': totalCount,
      'present': presentCount,
      'absent': absentCount,
      'synced': students.where((s) => s.isMarkedOnServer).length,
      'pending': students.where((s) => s.isPresent && !s.isMarkedOnServer).length,
    };
  }
}