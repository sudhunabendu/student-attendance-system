// lib/controllers/student_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/student_service.dart';
import '../models/class_model.dart';

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

  // Filters
  final selectedClass = 'All'.obs;
  final selectedStatus = 'All'.obs;
  final selectedGender = 'All'.obs;
  final searchQuery = ''.obs;

  // Selection
  final selectedStudentIds = <String>{}.obs;

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
  final statusOptions = ['All', 'Active', 'Inactive', 'Blocked'];
  final genderOptions = ['All', 'Male', 'Female', 'Other'];

  // ══════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════
  // String? get _authToken => _storage.read('token');

  int get presentCount => filteredStudents.where((s) => s.isPresent).length;
  int get absentCount => filteredStudents.length - presentCount;
  int get totalCount => filteredStudents.length;
  int get activeCount => filteredStudents.where((s) => s.isActive).length;
  int get maleCount =>
      filteredStudents.where((s) => s.gender.toLowerCase() == 'male').length;
  int get femaleCount =>
      filteredStudents.where((s) => s.gender.toLowerCase() == 'female').length;
  int get selectedCount => selectedStudentIds.length;

  bool get hasStudents => filteredStudents.isNotEmpty;
  bool get isFiltered =>
      selectedClass.value != 'All' ||
      selectedStatus.value != 'All' ||
      selectedGender.value != 'All' ||
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
  void onReady() {
    super.onReady();
    _fetchInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _initController() {
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
  }

  Future<void> _fetchInitialData() async {
    await Future.microtask(() async {
      await fetchClasses();
      await fetchStudents();
    });
  }

  // ══════════════════════════════════════════════════════════
  // FETCH CLASSES
  // ══════════════════════════════════════════════════════════
  // Future<void> fetchClasses() async {
  //   try {
  //     final result = await StudentService.getClasses();

  //     print('📥 Full Result: $result');
  //     print('📥 Success: ${result['success']}');
  //     print('📥 Classes Type: ${result['classes'].runtimeType}');
  //     print('📥 Classes Length: ${(result['classes'] as List?)?.length}');

  //     if (result['success'] == true) {
  //       final List<dynamic> classList = result['classes'] ?? [];

  //       print('📥 classList: $classList');

  //       // Parse one by one to find problematic item
  //       List<ClassModel> parsedClasses = [];
  //       for (int i = 0; i < classList.length; i++) {
  //         try {
  //           print('📥 Parsing class $i: ${classList[i]}');
  //           parsedClasses.add(ClassModel.fromJson(classList[i]));
  //           print('✅ Class $i parsed successfully');
  //         } catch (e) {
  //           print('❌ Error parsing class $i: $e');
  //         }
  //       }

  //       classes.value = parsedClasses;
  //       classOptions.value = ['All', ...classes.map((c) => c.name)];

  //       debugPrint('✅ Loaded ${classes.length} classes from API');
  //     } else {
  //       debugPrint('❌ Failed to load classes: ${result['message']}');
  //       _loadMockClasses();
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('❌ Error fetching classes: $e');
  //     debugPrint('📍 Stack trace: $stackTrace');
  //     _loadMockClasses();
  //   }
  // }

   Future<void> fetchClasses() async {
    try {
      final result = await StudentService.getClasses();
      
      print('📥 Classes Result: $result');
      
      if (result['success'] == true) {
        final List<dynamic> classList = result['classes'] ?? [];
        classes.value = classList.map((c) => ClassModel.fromJson(c)).toList();
        classOptions.value = ['All', ...classes.map((c) => c.name)];
        debugPrint('✅ Loaded ${classes.length} classes');
      } else {
        debugPrint('❌ Failed to load classes: ${result['message']}');
        _loadMockClasses();
      }
    } catch (e) {
      debugPrint('❌ Error fetching classes: $e');
      _loadMockClasses();
    }
  }

  void _loadMockClasses() {
    classOptions.value = ['All', '10th', '11th', '12th'];
  }

  // ══════════════════════════════════════════════════════════
  // FETCH STUDENTS
  // ══════════════════════════════════════════════════════════
  Future<void> fetchStudents({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !refresh) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // final token = _authToken;

      // If no token, load mock data
      // if (token == null) {
      //   _loadMockStudents();
      //   return;
      // }

      final result = await StudentService.getAllStudents(
        page: currentPage.value,
        limit: pageSize.value,
        classId: selectedClass.value != 'All'
            ? _getClassId(selectedClass.value)
            : null,
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

        if (pagination != null) {
          totalPages.value = pagination['totalPages'] ?? 1;
          totalStudents.value = pagination['total'] ?? students.length;
          hasMoreData.value = currentPage.value < totalPages.value;
        } else {
          hasMoreData.value = fetchedStudents.length >= pageSize.value;
        }

        _applyFilters();
      } else {
        // API failed, load mock data
        _loadMockStudents();
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      // On error, load mock data
      _loadMockStudents();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // MOCK DATA
  // ══════════════════════════════════════════════════════════
  void _loadMockStudents() {
    final mockStudents = List.generate(
      25,
      (index) => StudentModel(
        id: 'STU${(index + 1).toString().padLeft(3, '0')}',
        roleId: 'student',
        gender: index % 3 == 0 ? 'Female' : 'Male',
        firstName: _getFirstName(index),
        lastName: _getLastName(index),
        roleNumber: '2024${(index + 1).toString().padLeft(3, '0')}',
        email: 'student${index + 1}@school.com',
        mobileCode: '+91',
        mobileNumber: '98765${(10000 + index).toString()}',
        mobileNumberVerified: true,
        status: index % 10 == 0 ? 'Inactive' : 'Active',
        isOtpNeeded: false,
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
      ),
    );

    students.value = mockStudents;
    totalStudents.value = mockStudents.length;
    hasMoreData.value = false;
    _applyFilters();

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  String _getFirstName(int index) {
    final names = [
      'Aarav',
      'Vivaan',
      'Aditya',
      'Vihaan',
      'Arjun',
      'Sai',
      'Reyansh',
      'Ayaan',
      'Krishna',
      'Ishaan',
      'Ananya',
      'Aadhya',
      'Saanvi',
      'Aanya',
      'Pari',
      'Diya',
      'Myra',
      'Sara',
      'Ira',
      'Aisha',
      'Rahul',
      'Priya',
      'Amit',
      'Sneha',
      'Vikram',
    ];
    return names[index % names.length];
  }

  String _getLastName(int index) {
    final names = [
      'Sharma',
      'Patel',
      'Singh',
      'Kumar',
      'Gupta',
      'Mehta',
      'Joshi',
      'Reddy',
      'Nair',
      'Verma',
      'Rao',
      'Iyer',
      'Pillai',
      'Menon',
      'Das',
      'Bose',
      'Sen',
      'Roy',
      'Dey',
      'Ghosh',
      'Khan',
      'Ali',
      'Ahmed',
      'Siddiqui',
      'Ansari',
    ];
    return names[index % names.length];
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
    try {
      // First check local cache
      final cached = students.firstWhereOrNull((s) => s.id == studentId);
      if (cached != null) {
        selectedStudent.value = cached;
        return cached;
      }

      // final token = _authToken;
      // if (token == null) return null;

      final result = await StudentService.getStudentById(studentId: studentId);

      if (result['success'] == true && result['student'] != null) {
        selectedStudent.value = result['student'];
        return result['student'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching student: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENT ATTENDANCE
  // ══════════════════════════════════════════════════════════
  Future<void> fetchStudentAttendance(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // final token = _authToken;
      // if (token == null) {
      //   _loadMockAttendance();
      //   return;
      // }

      final result = await StudentService.getStudentAttendance(
        // token: token,
        studentId: studentId,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
      );

      if (result['success'] == true) {
        final List<dynamic> attendanceList = result['attendance'] ?? [];
        studentAttendance.value = AttendanceModel.fromJsonList(attendanceList);
      } else {
        _loadMockAttendance();
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      _loadMockAttendance();
    }
  }

  void _loadMockAttendance() {
    studentAttendance.value = List.generate(
      30,
      (index) => AttendanceModel(
        id: 'ATT${index + 1}',
        studentId: selectedStudent.value?.id ?? 'STU001',
        date: DateTime.now().subtract(Duration(days: index)),
        status: index % 5 == 0
            ? AttendanceStatus.absent
            : (index % 7 == 0
                  ? AttendanceStatus.late
                  : AttendanceStatus.present),
      ),
    );
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
      _applyFilters();
      return;
    }

    isSearching.value = true;

    if (searchQuery.value.length >= 2) {
      await fetchStudents(refresh: true);
    } else {
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

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.firstName.toLowerCase().contains(query) ||
            student.lastName.toLowerCase().contains(query) ||
            student.rollNumber.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            student.mobileNumber.contains(query);
      }).toList();
    }

    // Apply class filter
    if (selectedClass.value != 'All') {
      result = result.where((student) {
        return student.className == selectedClass.value;
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'All') {
      result = result.where((student) {
        return student.status.toLowerCase() ==
            selectedStatus.value.toLowerCase();
      }).toList();
    }

    // Apply gender filter
    if (selectedGender.value != 'All') {
      result = result.where((student) {
        return student.gender.toLowerCase() ==
            selectedGender.value.toLowerCase();
      }).toList();
    }

    filteredStudents.value = result;
  }

  void filterByClass(String className) {
    selectedClass.value = className;
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void filterByGender(String gender) {
    selectedGender.value = gender;
    _applyFilters();
  }

  void clearFilters() {
    selectedClass.value = 'All';
    selectedStatus.value = 'All';
    selectedGender.value = 'All';
    searchQuery.value = '';
    searchController.clear();
    _applyFilters();
  }

  // ══════════════════════════════════════════════════════════
  // SELECTION FUNCTIONALITY
  // ══════════════════════════════════════════════════════════
  void toggleStudentSelection(String studentId) {
    if (selectedStudentIds.contains(studentId)) {
      selectedStudentIds.remove(studentId);
    } else {
      selectedStudentIds.add(studentId);
    }

    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      students[index].isSelected = selectedStudentIds.contains(studentId);
      students.refresh();
    }
  }

  void selectAllStudents() {
    for (var student in filteredStudents) {
      selectedStudentIds.add(student.id);
      student.isSelected = true;
    }
    students.refresh();
  }

  void deselectAllStudents() {
    for (var student in students) {
      student.isSelected = false;
    }
    selectedStudentIds.clear();
    students.refresh();
  }

  List<StudentModel> getSelectedStudents() {
    return students.where((s) => selectedStudentIds.contains(s.id)).toList();
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

  Map<String, int> getStatusWiseCount() {
    final Map<String, int> counts = {};
    for (var student in students) {
      final status = student.status;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getGenderWiseCount() {
    final Map<String, int> counts = {};
    for (var student in students) {
      final gender = student.gender.isNotEmpty ? student.gender : 'Unknown';
      counts[gender] = (counts[gender] ?? 0) + 1;
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

    buffer.writeln('ID,Name,Roll Number,Class,Email,Mobile,Status,Gender');

    for (var student in filteredStudents) {
      buffer.writeln(
        '${student.id},'
        '"${student.name}",'
        '${student.rollNumber},'
        '${student.className ?? ""},'
        '${student.email},'
        '${student.mobileNumber},'
        '${student.status},'
        '${student.gender}',
      );
    }

    return buffer.toString();
  }
}
