// // lib/controllers/student_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/student_model.dart';

// class StudentController extends GetxController {
//   final isLoading = false.obs;
//   final students = <StudentModel>[].obs;
//   final filteredStudents = <StudentModel>[].obs;
//   final searchController = TextEditingController();
//   final selectedClass = 'All'.obs;
//   final selectedSection = 'All'.obs;

//   final classes = ['All', '10th', '11th', '12th'];
//   final sections = ['All', 'A', 'B', 'C', 'D'];

//   @override
//   void onInit() {
//     super.onInit();
//     fetchStudents();
//     searchController.addListener(_filterStudents);
//   }

//   Future<void> fetchStudents() async {
//     isLoading.value = true;
    
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 1));
    
//     // Mock data
//     students.value = List.generate(
//       30,
//       (index) => StudentModel(
//         id: 'STU${index + 1}',
//         name: 'Student ${index + 1}',
//         rollNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
//         className: ['10th', '11th', '12th'][index % 3],
//         section: ['A', 'B', 'C', 'D'][index % 4],
//         parentPhone: '+1234567890',
//       ),
//     );
    
//     filteredStudents.value = students;
//     isLoading.value = false;
//   }

//   void _filterStudents() {
//     String query = searchController.text.toLowerCase();
    
//     filteredStudents.value = students.where((student) {
//       bool matchesSearch = student.name.toLowerCase().contains(query) ||
//           student.rollNumber.toLowerCase().contains(query);
//       bool matchesClass = selectedClass.value == 'All' ||
//           student.className == selectedClass.value;
//       bool matchesSection = selectedSection.value == 'All' ||
//           student.section == selectedSection.value;
      
//       return matchesSearch && matchesClass && matchesSection;
//     }).toList();
//   }

//   void filterByClass(String className) {
//     selectedClass.value = className;
//     _filterStudents();
//   }

//   void filterBySection(String section) {
//     selectedSection.value = section;
//     _filterStudents();
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }
// }

// lib/controllers/student_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/student_service.dart';

class StudentController extends GetxController {
  // ══════════════════════════════════════════════════════════
  // OBSERVABLES
  // ══════════════════════════════════════════════════════════
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSearching = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Students data
  final students = <StudentModel>[].obs;
  final filteredStudents = <StudentModel>[].obs;
  final selectedStudent = Rxn<StudentModel>();
  final studentAttendance = <AttendanceModel>[].obs;
  
  // Classes data
  final classes = <ClassModel>[].obs;
  final sections = <String>[].obs;
  
  // Filters
  final selectedClass = 'All'.obs;
  final selectedSection = 'All'.obs;
  final selectedStatus = 'All'.obs;
  final searchQuery = ''.obs;
  
  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalStudents = 0.obs;
  final pageSize = 20.obs;
  final hasMoreData = true.obs;
  
  // Controllers
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  
  // Debounce timer for search
  Timer? _debounceTimer;
  
  // Storage
  final _storage = GetStorage();
  
  // Filter options
  final classOptions = <String>['All'].obs;
  final sectionOptions = ['All', 'A', 'B', 'C', 'D'];
  final statusOptions = ['All', 'Active', 'Inactive', 'Blocked'];

  // ══════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════
  String? get _authToken => _storage.read('token');
  
  int get presentCount => filteredStudents.where((s) => s.isPresent).length;
  int get absentCount => filteredStudents.length - presentCount;
  int get totalCount => filteredStudents.length;
  
  bool get hasStudents => filteredStudents.isNotEmpty;
  bool get isFiltered => 
      selectedClass.value != 'All' || 
      selectedSection.value != 'All' ||
      selectedStatus.value != 'All' ||
      searchQuery.value.isNotEmpty;

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
    scrollController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _initController() {
    // Setup search listener with debounce
    searchController.addListener(_onSearchChanged);
    
    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);
    
    // Initial data fetch
    fetchClasses();
    fetchStudents();
  }

  // ══════════════════════════════════════════════════════════
  // FETCH CLASSES
  // ══════════════════════════════════════════════════════════
  Future<void> fetchClasses() async {
    if (_authToken == null) return;

    try {
      final result = await StudentService.getClasses(token: _authToken!);

      if (result['success'] == true) {
        final List<dynamic> classList = result['classes'] ?? [];
        classes.value = classList.map((c) => ClassModel.fromJson(c)).toList();
        
        // Update class options for dropdown
        classOptions.value = ['All', ...classes.map((c) => c.name)];
        
        // Update sections if available
        final allSections = classes
            .where((c) => c.section != null)
            .map((c) => c.section!)
            .toSet()
            .toList();
        if (allSections.isNotEmpty) {
          sections.value = allSections;
        }
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // FETCH STUDENTS
  // ══════════════════════════════════════════════════════════
  Future<void> fetchStudents({bool refresh = false}) async {
    if (_authToken == null) {
      _showAuthError();
      return;
    }

    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !refresh) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await StudentService.getAllStudents(
        token: _authToken!,
        page: currentPage.value,
        limit: pageSize.value,
        classId: selectedClass.value != 'All' ? _getClassId(selectedClass.value) : null,
        section: selectedSection.value != 'All' ? selectedSection.value : null,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value != 'All' ? selectedStatus.value : null,
      );

      if (result['success'] == true) {
        final List<StudentModel> fetchedStudents = result['students'] ?? [];
        final pagination = result['pagination'];

        if (refresh || currentPage.value == 1) {
          students.value = fetchedStudents;
        } else {
          students.addAll(fetchedStudents);
        }

        // Update pagination info
        if (pagination != null) {
          totalPages.value = pagination['totalPages'] ?? 1;
          totalStudents.value = pagination['total'] ?? students.length;
          hasMoreData.value = currentPage.value < totalPages.value;
        } else {
          hasMoreData.value = fetchedStudents.length >= pageSize.value;
        }

        // Apply local filters
        _applyFilters();
      } else {
        hasError.value = true;
        errorMessage.value = result['message'] ?? 'Failed to fetch students';
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Network error: $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD MORE (PAGINATION)
  // ══════════════════════════════════════════════════════════
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;
    await fetchStudents();
  }

  // ══════════════════════════════════════════════════════════
  // REFRESH STUDENTS
  // ══════════════════════════════════════════════════════════
  Future<void> refreshStudents() async {
    await fetchStudents(refresh: true);
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENT BY ID
  // ══════════════════════════════════════════════════════════
  Future<StudentModel?> getStudentById(String studentId) async {
    if (_authToken == null) {
      _showAuthError();
      return null;
    }

    try {
      // First check local cache
      final cached = students.firstWhereOrNull((s) => s.id == studentId);
      if (cached != null) {
        selectedStudent.value = cached;
        return cached;
      }

      // Fetch from API
      final result = await StudentService.getStudentById(
        token: _authToken!,
        studentId: studentId,
      );

      if (result['success'] == true && result['student'] != null) {
        selectedStudent.value = result['student'];
        return result['student'];
      } else {
        _showErrorSnackbar(result['message'] ?? 'Student not found');
        return null;
      }
    } catch (e) {
      _showErrorSnackbar('Error fetching student: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENT ATTENDANCE
  // ══════════════════════════════════════════════════════════
  Future<void> fetchStudentAttendance(String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_authToken == null) {
      _showAuthError();
      return;
    }

    try {
      final result = await StudentService.getStudentAttendance(
        token: _authToken!,
        studentId: studentId,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
      );

      if (result['success'] == true) {
        final List<dynamic> attendanceList = result['attendance'] ?? [];
        studentAttendance.value = AttendanceModel.fromJsonList(attendanceList);
      } else {
        _showErrorSnackbar(result['message'] ?? 'Failed to fetch attendance');
      }
    } catch (e) {
      _showErrorSnackbar('Error fetching attendance: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH FUNCTIONALITY
  // ══════════════════════════════════════════════════════════
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text.trim();
      if (query != searchQuery.value) {
        searchQuery.value = query;
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    if (searchQuery.value.isEmpty) {
      // Reset to all students
      _applyFilters();
      return;
    }

    isSearching.value = true;

    // If query is long enough, search from server
    if (searchQuery.value.length >= 2) {
      await fetchStudents(refresh: true);
    } else {
      // Just filter locally
      _applyFilters();
    }

    isSearching.value = false;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // FILTER FUNCTIONALITY
  // ══════════════════════════════════════════════════════════
  void _applyFilters() {
    List<StudentModel> result = List.from(students);

    // Apply search filter (local)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.firstName.toLowerCase().contains(query) ||
            student.lastName.toLowerCase().contains(query) ||
            (student.rollNumber?.toLowerCase().contains(query) ?? false) ||
            (student.email?.toLowerCase().contains(query) ?? false) ||
            (student.mobileNumber?.contains(query) ?? false);
      }).toList();
    }

    // Apply class filter (local - in case server didn't filter)
    if (selectedClass.value != 'All') {
      result = result.where((student) {
        return student.className == selectedClass.value;
      }).toList();
    }

    // Apply section filter (local)
    if (selectedSection.value != 'All') {
      result = result.where((student) {
        return student.section == selectedSection.value;
      }).toList();
    }

    // Apply status filter (local)
    if (selectedStatus.value != 'All') {
      result = result.where((student) {
        return student.status.value == selectedStatus.value;
      }).toList();
    }

    filteredStudents.value = result;
  }

  void filterByClass(String className) {
    selectedClass.value = className;
    fetchStudents(refresh: true);
  }

  void filterBySection(String section) {
    selectedSection.value = section;
    fetchStudents(refresh: true);
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchStudents(refresh: true);
  }

  void clearFilters() {
    selectedClass.value = 'All';
    selectedSection.value = 'All';
    selectedStatus.value = 'All';
    searchQuery.value = '';
    searchController.clear();
    fetchStudents(refresh: true);
  }

  // ══════════════════════════════════════════════════════════
  // ATTENDANCE MARKING (LOCAL STATE)
  // ══════════════════════════════════════════════════════════
  void toggleStudentPresent(String studentId) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      students[index].isPresent = !students[index].isPresent;
      students.refresh();
      _applyFilters();
    }
  }

  void markAllPresent() {
    for (var student in students) {
      student.isPresent = true;
    }
    students.refresh();
    _applyFilters();
  }

  void markAllAbsent() {
    for (var student in students) {
      student.isPresent = false;
    }
    students.refresh();
    _applyFilters();
  }

  void setStudentLoading(String studentId, bool loading) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      students[index].isLoading = loading;
      students.refresh();
    }
  }

  void setStudentMarkedOnServer(String studentId, bool marked) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      students[index].isMarkedOnServer = marked;
      students.refresh();
    }
  }

  // ══════════════════════════════════════════════════════════
  // SCROLL LISTENER FOR PAGINATION
  // ══════════════════════════════════════════════════════════
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════
  String? _getClassId(String className) {
    final classModel = classes.firstWhereOrNull((c) => c.name == className);
    return classModel?.id;
  }

  void _showAuthError() {
    _showErrorSnackbar('Authentication required. Please login again.');
    // Optionally navigate to login
    // Get.offAllNamed('/login');
  }

  void _showErrorSnackbar(String message) {
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

  void _showSuccessSnackbar(String message) {
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

  // ══════════════════════════════════════════════════════════
  // FIND STUDENT METHODS
  // ══════════════════════════════════════════════════════════
  StudentModel? findById(String id) {
    return students.firstWhereOrNull((s) => s.id == id);
  }

  StudentModel? findByRollNumber(String rollNumber) {
    return students.firstWhereOrNull((s) => s.rollNumber == rollNumber);
  }

  StudentModel? findByEmail(String email) {
    return students.firstWhereOrNull((s) => s.email == email);
  }

  List<StudentModel> findByClass(String className) {
    return students.where((s) => s.className == className).toList();
  }

  // ══════════════════════════════════════════════════════════
  // STATISTICS
  // ══════════════════════════════════════════════════════════
  Map<String, int> getClassWiseCount() {
    final Map<String, int> counts = {};
    for (var student in students) {
      final className = student.className ?? 'Unknown';
      counts[className] = (counts[className] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getSectionWiseCount() {
    final Map<String, int> counts = {};
    for (var student in students) {
      final section = student.section ?? 'Unknown';
      counts[section] = (counts[section] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getStatusWiseCount() {
    final Map<String, int> counts = {};
    for (var student in students) {
      final status = student.status.value;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  // ══════════════════════════════════════════════════════════
  // EXPORT DATA
  // ══════════════════════════════════════════════════════════
  List<Map<String, dynamic>> exportToJson() {
    return filteredStudents.map((s) => s.toJson()).toList();
  }

  String exportToCsv() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('ID,Name,Roll Number,Class,Section,Email,Mobile,Status');
    
    // Data rows
    for (var student in filteredStudents) {
      buffer.writeln(
        '${student.id},'
        '${student.name},'
        '${student.rollNumber ?? ""},'
        '${student.className ?? ""},'
        '${student.section ?? ""},'
        '${student.email ?? ""},'
        '${student.mobileNumber ?? ""},'
        '${student.status.value}'
      );
    }
    
    return buffer.toString();
  }
}