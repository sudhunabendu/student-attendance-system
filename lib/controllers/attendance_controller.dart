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
// import 'package:flutter/foundation.dart'; // ✅ Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_response_model.dart'; // ✅ Add this import
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
  
  // ✅ Add attendance records list
  final attendanceRecords = <AttendanceResponseModel>[].obs;
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
  final lateCount = 0.obs; // ✅ Add late count

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
  
  // ✅ Add late students count
  int get lateStudentsCount => students.where((s) => s.status == 'late').length;

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
      
        // ✅ Use typed result
        final result = await AttendanceService.getAttendanceHistory(
          startDate: startDate,
          endDate: endDate,
          classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
          studentId: studentId,
        );
        // print("Fetched attendance history: $result");
        // ✅ Access properties directly
        if (result.success) {
          // Convert AttendanceResponseModel to AttendanceModel if needed
          attendanceHistory.value = result.records.map((record) => 
            AttendanceModel(
              id: record.attendanceId ?? '',
              studentId: record.studentId ?? '',
              studentName: record.fullName,
              studentRollNumber: record.rollNumber ?? '',
              studentClassName: record.className ?? '',
              studentSection: '',
              date: record.date ?? DateTime.now(),
              status: _parseAttendanceStatus(record.status),
              checkInTime: record.checkInTime,
              createdAt: record.createdAt,
            )
          ).toList();
          
          // debugPrint('✅ Fetched ${result.records.length} history records');
        } else {
          // debugPrint('❌ ${result.message}');
          _loadMockAttendanceHistory();
        }
      
    } catch (e) {
      _showErrorSnackbar('Failed to fetch history: $e');
      _loadMockAttendanceHistory();
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// ✅ Safe enum parsing with fallback
AttendanceStatus _parseAttendanceStatus(String? status) {
  if (status == null || status.isEmpty) {
    return AttendanceStatus.absent;
  }
  
  switch (status.toLowerCase().trim()) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'excused':
      return AttendanceStatus.excused;
   // If you have this enum value
    default:
      // debugPrint('⚠️ Unknown attendance status: $status, defaulting to absent');
      return AttendanceStatus.absent;
  }
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
    final result = await AttendanceService.getAttendanceHistory(
      startDate: startDate,
      endDate: endDate,
      classId: selectedClassId.value.isNotEmpty ? selectedClassId.value : null,
      section: selectedSection.value,
      studentId: studentId,
    );

    if (result.success) {
      attendanceHistory.value = result.records.map((record) {
        return AttendanceModel(
          id: record.attendanceId ?? '',
          studentId: record.studentId ?? '',                    // ✅ Getter already handles null
          studentName: record.fullName.isNotEmpty 
              ? record.fullName 
              : 'Unknown',                                // ✅ Fallback for empty name
          studentRollNumber: record.rollNumber,           // ✅ Getter already handles null
          studentClassName: record.className,             // ✅ Getter already handles null
          studentSection: '',
          date: record.date ?? DateTime.now(),
          status: _parseAttendanceStatus(record.status),  // ✅ Safe parsing
          checkInTime: record.checkInTime,
          createdAt: record.createdAt,
        );
      }).toList();
      
      // debugPrint('✅ Fetched ${result.records.length} history records');
    } else {
      // debugPrint('❌ ${result.message}');
      _loadMockAttendanceHistory();
    }
  } catch (e, stackTrace) {
    // debugPrint('❌ Failed to fetch history: $e');
    // debugPrint('📍 StackTrace: $stackTrace');
    _showErrorSnackbar('Failed to fetch history');
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
  Future<Map<String, dynamic>> markSingleStudentAttendance(String studentId) async {
    if (!isAuthenticated) {
      _showErrorSnackbar('Authentication required. Please login again.');
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final result = await AttendanceService.markAttendance(
        // token: _authToken!,
        studentId: studentId,
      );

      // debugPrint('📥 Mark Attendance Result: $result');

      if (result['success'] == true) {
        if (result['alreadyMarked'] == true) {
          _showInfoSnackbar(result['message'] ?? 'Already marked');
        } else {
          final status = result['status'] ?? 'present';
          final message = result['message'] ?? 'Attendance marked as $status';
          
          if (status == 'late') {
            _showWarningSnackbar(message);
          } else {
            _showSuccessSnackbar(message);
          }
        }
        return result;
      } else {
        _showErrorSnackbar(result['message'] ?? 'Failed to mark attendance');
        return result;
      }
    } catch (e) {
      // debugPrint('❌ Mark Attendance Error: $e');
      _showErrorSnackbar('Network error: $e');
      return {'success': false, 'message': e.toString()};
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

    final result = await markSingleStudentAttendance(student.id);

    if (result['success'] == true) {
      student.isPresent = true;
      student.isMarkedOnServer = true;
      
      // ✅ Update attendance status from response
      final status = result['status'] ?? result['data']?['status'] ?? 'present';
      student.attendanceStatus = status;
      
      // debugPrint('✅ ${student.name} marked as $status');
    }

    student.isLoading = false;
    students.refresh();
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // SAVE ALL ATTENDANCE - FIXED VERSION
  // ══════════════════════════════════════════════════════════
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
    lateCount.value = 0; // ✅ Reset late count

    final List<AttendanceResultItem> results = [];

    for (int i = 0; i < studentsToMark.length; i++) {
      final student = studentsToMark[i];
      currentProgress.value = i + 1;

      try {
        final result = await AttendanceService.markAttendance(
          // token: _authToken!,
          studentId: student.id,
        );

        // debugPrint('📥 Response for ${student.name}: $result');

        if (result['success'] == true) {
          // ✅ Get actual status from response - handle nested data
          String markedStatus = 'present';
          
          // Try to get status from different possible locations
          if (result['status'] != null) {
            markedStatus = result['status'].toString();
          } else if (result['data'] != null && result['data']['status'] != null) {
            markedStatus = result['data']['status'].toString();
          } else if (result['attendanceRecord'] != null) {
            final record = result['attendanceRecord'];
            if (record is AttendanceResponseModel) {
              markedStatus = record.status;
            }
          }

          // Check if already marked
          if (result['alreadyMarked'] == true) {
            alreadyMarkedCount.value++;
          } else {
            successCount.value++;
            
            // ✅ Track late count
            if (markedStatus.toLowerCase() == 'late') {
              lateCount.value++;
            }
          }

          // ✅ Update student with server response
          student.isMarkedOnServer = true;
          student.attendanceStatus = markedStatus;

          results.add(AttendanceResultItem(
            studentName: student.name,
            rollNumber: student.rollNumber ?? '',
            status: markedStatus,
            success: true,
            checkInTime: result['formattedCheckInTime'] ?? result['checkInTime']?.toString(),
          ));

          // debugPrint('✅ ${student.name} → $markedStatus');
        } else {
          failedStudents.add(student);
          results.add(AttendanceResultItem(
            studentName: student.name,
            rollNumber: student.rollNumber ?? '',
            status: 'failed',
            success: false,
            error: result['message'] ?? 'Unknown error',
          ));
          
          // debugPrint('❌ ${student.name} → Failed: ${result['message']}');
        }
      } catch (e) {
        failedStudents.add(student);
        results.add(AttendanceResultItem(
          studentName: student.name,
          rollNumber: student.rollNumber ?? '',
          status: 'error',
          success: false,
          error: e.toString(),
        ));
        
        // debugPrint('❌ Error for ${student.name}: $e');
      }

      // Small delay to prevent rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    students.refresh();
    isSaving.value = false;

    // ✅ Show detailed result summary
    _showDetailedResultSummary(results);

    if (failedStudents.isEmpty) {
      await Future.delayed(const Duration(seconds: 3));
      Get.back(result: true);
    }
  }

  // ══════════════════════════════════════════════════════════
  // SHOW DETAILED RESULT SUMMARY
  // ══════════════════════════════════════════════════════════
  void _showDetailedResultSummary(List<AttendanceResultItem> results) {
    final presentItems = results.where((r) => r.status.toLowerCase() == 'present').toList();
    final lateItems = results.where((r) => r.status.toLowerCase() == 'late').toList();
    final failedItems = results.where((r) => !r.success).toList();

    final message = StringBuffer();

    if (presentItems.isNotEmpty) {
      message.writeln('✅ Present: ${presentItems.length}');
    }
    if (lateItems.isNotEmpty) {
      message.writeln('⏰ Late: ${lateItems.length}');
      // Show late students' names
      for (var item in lateItems.take(3)) {
        message.writeln('   • ${item.studentName}');
      }
      if (lateItems.length > 3) {
        message.writeln('   ... and ${lateItems.length - 3} more');
      }
    }
    if (alreadyMarkedCount.value > 0) {
      message.writeln('📋 Already marked: ${alreadyMarkedCount.value}');
    }
    if (failedItems.isNotEmpty) {
      message.writeln('❌ Failed: ${failedItems.length}');
    }
    message.write('🚫 Absent: $absentCount');

    // Determine snackbar color based on results
    Color bgColor = Colors.green;
    if (failedItems.isNotEmpty) {
      bgColor = Colors.red;
    } else if (lateItems.isNotEmpty) {
      bgColor = Colors.orange;
    }

    Get.snackbar(
      'Attendance Summary',
      message.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(10),
      isDismissible: true,
      mainButton: lateItems.isNotEmpty
          ? TextButton(
              onPressed: () => _showLateStudentsDialog(lateItems),
              child: const Text(
                'View Late',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  // ══════════════════════════════════════════════════════════
  // SHOW LATE STUDENTS DIALOG
  // ══════════════════════════════════════════════════════════
  void _showLateStudentsDialog(List<AttendanceResultItem> lateItems) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Late Students'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lateItems.length,
            itemBuilder: (context, index) {
              final item = lateItems[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    item.studentName.isNotEmpty 
                        ? item.studentName[0].toUpperCase() 
                        : 'S',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
                title: Text(item.studentName),
                subtitle: Text('Roll: ${item.rollNumber}'),
                trailing: Text(
                  item.checkInTime ?? '--:--',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
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
          // token: _authToken!,
          studentId: student.id,
        );

        if (result['success'] == true) {
          retrySuccess++;
          student.isMarkedOnServer = true;
          student.isPresent = result['status'] ?? 'present';
          successCount.value++;
        } else {
          failedStudents.add(student);
        }
      } catch (e) {
        failedStudents.add(student);
        // debugPrint('❌ Retry error for ${student.name}: $e');
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
  // SET CLASS ID (from external source like QR scanner)
  // ══════════════════════════════════════════════════════════
  void setClassId(String classId) {
    selectedClassId.value = classId;
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
        icon: const Icon(Icons.check_circle, color: Colors.white),
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
        icon: const Icon(Icons.error, color: Colors.white),
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
        icon: const Icon(Icons.warning, color: Colors.white),
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
        icon: const Icon(Icons.info, color: Colors.white),
      );
    }
  }

  void _showResultSummary() {
    final message = StringBuffer();

    if (successCount.value > 0) {
      message.writeln('✅ Marked: ${successCount.value}');
    }
    if (lateCount.value > 0) {
      message.writeln('⏰ Late: ${lateCount.value}');
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
      'late': lateStudentsCount,
      'synced': students.where((s) => s.isMarkedOnServer).length,
      'pending': students.where((s) => s.isPresent && !s.isMarkedOnServer).length,
    };
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENTS BY STATUS
  // ══════════════════════════════════════════════════════════
  List<StudentModel> getStudentsByStatus(String status) {
    return students.where((s) => s.attendanceStatus.toLowerCase() == status.toLowerCase()).toList();
  }

  List<StudentModel> get lateStudents => getStudentsByStatus('late');
  List<StudentModel> get presentStudents => getStudentsByStatus('present');
  List<StudentModel> get absentStudents => students.where((s) => !s.isPresent).toList();
  
  get studentId => null;
  
  get endDate => null;
  
  get startDate => null;
}

// ══════════════════════════════════════════════════════════
// ATTENDANCE RESULT ITEM MODEL
// ══════════════════════════════════════════════════════════
class AttendanceResultItem {
  final String studentName;
  final String rollNumber;
  final String status;
  final bool success;
  final String? error;
  final String? checkInTime;

  AttendanceResultItem({
    required this.studentName,
    required this.rollNumber,
    required this.status,
    required this.success,
    this.error,
    this.checkInTime,
  });

  bool get isLate => status.toLowerCase() == 'late';
  bool get isPresent => status.toLowerCase() == 'present';

  @override
  String toString() {
    return 'AttendanceResultItem(student: $studentName, status: $status, success: $success)';
  }
}