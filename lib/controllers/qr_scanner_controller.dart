// lib/controllers/qr_scanner_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../services/storage_service.dart';
import '../services/student_service.dart';
import '../app/theme/app_theme.dart';
import '../app/utils/qr_helper.dart';

class QRScannerController extends GetxController {
  // ══════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ══════════════════════════════════════════════════════════
  final StorageService _storageService = StorageService();

  // ══════════════════════════════════════════════════════════
  // SCANNER STATE
  // ══════════════════════════════════════════════════════════
  final isScanning = true.obs;
  final isFlashOn = false.obs;
  final isFrontCamera = false.obs;
  final isProcessing = false.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // ══════════════════════════════════════════════════════════
  // LOADING STATES
  // ══════════════════════════════════════════════════════════
  final isLoadingStudents = false.obs;
  final studentsLoadError = ''.obs;

  // ══════════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════════
  final scannedStudents = <StudentModel>[].obs;
  final todayAttendance = <AttendanceModel>[].obs;
  final allStudents = <StudentModel>[].obs;
  final selectedDate = DateTime.now().obs;

  // ══════════════════════════════════════════════════════════
  // SCANNER CONTROLLER
  // ══════════════════════════════════════════════════════════
  MobileScannerController? scannerController;

  // ══════════════════════════════════════════════════════════
  // DUPLICATE PREVENTION
  // ══════════════════════════════════════════════════════════
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const int _scanCooldownSeconds = 2;

  // ══════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════
  String? get _authToken => _storageService.getToken();
  // bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  int get presentCount => scannedStudents.length;
  int get totalStudents => allStudents.length;

  double get attendancePercentage =>
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;

  String get formattedDate {
    final date = selectedDate.value;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get dateString {
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
    scannerController?.dispose();
    super.onClose();
  }

  Future<void> _initController() async {
    initScanner();

    // Load students from API
    await loadStudentsFromAPI();
    await fetchTodayAttendance();

    // Fallback to mock data if not authenticated
    _loadMockStudents();
  }

  // ══════════════════════════════════════════════════════════
  // SCANNER INITIALIZATION
  // ══════════════════════════════════════════════════════════
  void initScanner() {
    try {
      scannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 1000,
      );
      hasError.value = false;
      errorMessage.value = '';
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize camera: $e';
      // debugPrint('Scanner init error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD STUDENTS FROM API
  // ══════════════════════════════════════════════════════════
  Future<void> loadStudentsFromAPI() async {
    isLoadingStudents.value = true;
    studentsLoadError.value = '';

    try {
      // debugPrint('Fetching students from API...');

      final result = await StudentService.getAllStudents();

      // debugPrint('Students API Response: success=${result['success']}');

      if (result['success'] == true) {
        // ✅ Students are already parsed as List<StudentModel>
        final List<StudentModel> students = result['students'] ?? [];

        allStudents.value = students;

        // debugPrint('✓ Loaded ${allStudents.length} students from API');
      } else {
        studentsLoadError.value =
            result['message'] ?? 'Failed to load students';
        // debugPrint('✗ Failed to load students: ${result['message']}');

        // Fallback to mock data
        _loadMockStudents();
      }
    } catch (e, stackTrace) {
      // debugPrint('✗ Error loading students: $e');
      // debugPrint('Stack trace: $stackTrace');
      studentsLoadError.value = 'Error: $e';

      // Fallback to mock data
      _loadMockStudents();
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // REFRESH STUDENTS
  // ══════════════════════════════════════════════════════════
  Future<void> refreshStudents() async {
    await loadStudentsFromAPI();

    if (studentsLoadError.value.isEmpty) {
      _showInfo('Refreshed', 'Student list updated');
    } else {
      _showError('Error', studentsLoadError.value);
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD MOCK STUDENTS (Fallback)
  // ══════════════════════════════════════════════════════════
  void _loadMockStudents() {
    // debugPrint('Loading mock students as fallback...');

    allStudents.value = List.generate(
      50,
      (index) => StudentModel(
        id: 'STU${index + 1}',
        roleId: 'student',
        gender: index % 2 == 0 ? 'Male' : 'Female',
        firstName: 'Student',
        lastName: '${index + 1}',
        roleNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
        email: 'student${index + 1}@school.com',
        mobileCode: '+91',
        mobileNumber: '98765${(index + 1).toString().padLeft(5, '0')}',
        mobileNumberVerified: true,
        status: 'Active',
        isOtpNeeded: false,
      ),
    );

    // debugPrint('Loaded ${allStudents.length} mock students');
  }

  // ══════════════════════════════════════════════════════════
  // FIND STUDENT BY ID (API or Local)
  // ══════════════════════════════════════════════════════════
  Future<StudentModel?> findStudentById(String studentId) async {
    // First, try to find in local list
    StudentModel? student = allStudents.firstWhereOrNull(
      (s) => s.id == studentId,
    );

    if (student != null) {
      // debugPrint('✓ Found student locally: ${student.name}');
      return student;
    }

    // If not found locally, try API
    try {
      // debugPrint('Student not found locally, fetching from API...');

      final result = await StudentService.getStudentById(studentId: studentId);

      // debugPrint('API Result: $result');

      if (result['success'] == true && result['student'] != null) {
        // ✅ Student is already parsed as StudentModel in the service
        student = result['student'] as StudentModel;

        // Add to local list if not already exists
        if (!allStudents.any((s) => s.id == student!.id)) {
          allStudents.add(student);
        }

        // debugPrint('✓ Found student from API: ${student.name}');
        return student;
      } else {
        // debugPrint('✗ Student not found: ${result['message']}');
      }
    } catch (e) {
      // debugPrint('❌ Error fetching student by ID: $e');
    }

    return null;
  }

  // ══════════════════════════════════════════════════════════
  // FETCH TODAY'S ATTENDANCE FROM SERVER
  // ══════════════════════════════════════════════════════════
  Future<void> fetchTodayAttendance() async {
    try {
      final result = await AttendanceService.getTodayAttendance(
        // token: _authToken!,
      );

      if (result['success'] == true) {
        todayAttendance.value = result['attendance'] ?? [];

        // Mark already attended students
        for (var attendance in todayAttendance) {
          final student = allStudents.firstWhereOrNull(
            (s) => s.id == attendance.studentId,
          );
          if (student != null && !scannedStudents.contains(student)) {
            final updatedStudent = student.copyWith(
              isPresent: true,
              isMarkedOnServer: true,
              attendanceStatus: attendance.status.name,
            );
            scannedStudents.add(updatedStudent);
          }
        }
      }
    } catch (e) {
      // debugPrint('Error fetching today attendance: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // BARCODE DETECTION HANDLER
  // ══════════════════════════════════════════════════════════
  void onBarcodeDetected(BarcodeCapture capture) {
    if (isProcessing.value) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        processQRCode(barcode.rawValue!);
        break;
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // SCANNER ERROR HANDLER
  // ══════════════════════════════════════════════════════════
  void onScannerError(MobileScannerException error, StackTrace? stackTrace) {
    hasError.value = true;
    errorMessage.value = 'Camera error: ${error.errorCode.name}';
    // debugPrint('Scanner error: ${error.errorCode.name}');
  }

  // ══════════════════════════════════════════════════════════
  // PROCESS QR CODE
  // ══════════════════════════════════════════════════════════
  Future<void> processQRCode(String code) async {
    // Prevent duplicate scans
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < _scanCooldownSeconds) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;
    isProcessing.value = true;

    try {
      // ✅ Parse QR code data using helper
      final qrData = QRHelper.parseQRCode(code);
      // debugPrint('Scanned QR Data: $qrData');

      if (qrData == null) {
        _showError('Invalid QR Code', 'This QR code is not valid.');
        isProcessing.value = false;
        return;
      }

      // Check QR validity
      if (qrData['isValid'] != true) {
        _showWarning('Expired QR', 'This QR code has expired.');
        isProcessing.value = false;
        return;
      }

      final studentId = qrData['id'] as String;

      // ✅ Find student using API-aware method
      final student = await findStudentById(studentId);
      // debugPrint('Found student: $student');
      if (student == null) {
        _showError('Not Found', 'No student found with ID: $studentId');
        isProcessing.value = false;
        return;
      }

      // Check if already scanned
      final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
      if (alreadyScanned) {
        _showWarning(
          'Already Marked',
          '${student.name} is already marked present.',
        );
        isProcessing.value = false;
        return;
      }

      // Mark attendance
      await markAttendance(student);
    } catch (e) {
      _showError('Error', 'Failed to process QR code: $e');
      // debugPrint('QR process error: $e');
    }

    isProcessing.value = false;
  }

  Future<void> markAttendance(StudentModel student) async {
    _vibrate();

    bool serverSuccess = false;
    String markedStatus = 'present';
    String? attendanceId;
    DateTime? checkInTime;
    DateTime? checkOutTime;
    String action = 'check_in'; // default

    try {
      final result = await AttendanceService.markAttendance(
        studentId: student.id,
      );

      final bool success = result['success'] == true;
      action = result['action'] ?? 'check_in';
      debugPrint('action: $action');
      if (success) {
        serverSuccess = true;

        // status can be at the root or in data
        markedStatus =
            result['status'] ?? result['data']?['status'] ?? 'present';

        // attendance id
        attendanceId =
            result['attendanceId'] ??
            result['data']?['_id'] ??
            result['data']?['attendance_id'];

        // times
        final checkInTimeStr =
            result['checkInTime'] ?? result['data']?['check_in_time'];
        final checkOutTimeStr =
            result['checkOutTime'] ?? result['data']?['check_out_time'];

        if (checkInTimeStr is String && checkInTimeStr.isNotEmpty) {
          checkInTime = DateTime.parse(checkInTimeStr);
        }

        if (checkOutTimeStr is String && checkOutTimeStr.isNotEmpty) {
          checkOutTime = DateTime.parse(checkOutTimeStr);
        }

        // Handle specific actions from backend
        if (action == 'check_in') {
          // normal first scan
          _showAttendanceSuccess(
            student.name,
            markedStatus,
            serverSuccess,
            action: 'check_in',
          );
        } else if (action == 'check_out') {
          // successful checkout
          _showAttendanceSuccess(
            student.name,
            markedStatus,
            serverSuccess,
            action: 'check_out',
          );
        } else if (action == 'already_checked_out') {
          _showWarning(
            'Already Checked Out',
            '${student.name} is already checked out for today.',
          );
          // Optionally, still record locally or just return
          return;
        } else if (action == 'too_early_for_checkout') {
          _showWarning(
            'Too Early',
            result['message'] ?? 'Cannot checkout yet.',
          );
          return;
        } else {
          // fallback
          _showAttendanceSuccess(
            student.name,
            markedStatus,
            serverSuccess,
            action: action,
          );
        }
      } else {
        // Handle non-success from server
        if (result['alreadyMarked'] == true) {
          // Old behavior if your backend still uses this flag somewhere
          _showWarning('Already Marked', '${student.name} was already marked.');
          return;
        }

        // Some error from server
        _showWarning(
          'Error',
          result['message'] ?? 'Failed to mark attendance.',
        );
        // You can decide whether to still add locally or not
      }
    } catch (e, stack) {
      debugPrint('Attendance error: $e');
      debugPrintStack(stackTrace: stack);
      // API Error (network, etc.)
      // _showWarning('Network Error', 'Could not reach server. Saved locally.');
      // You keep serverSuccess = false and fall through to local save
      _showWarning(
        'Error',
        'Attendance saved on server but app failed to process response.',
      );
    }

    // -------------------------
    // CREATE LOCAL RECORD
    // -------------------------

    // For check-out, you might want different handling, but
    // here I always create/update a local attendance record.

    final updatedStudent = student.copyWith(
      isPresent: true,
      isMarkedOnServer: serverSuccess,
      attendanceStatus: markedStatus,
    );

    scannedStudents.add(updatedStudent);

    final attendance = AttendanceModel(
      id: attendanceId ?? 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
      studentId: student.id,
      studentName: student.name,
      studentRollNumber: student.rollNumber,
      studentClassName: student.className,
      studentSection: student.section,
      date: DateTime.now(),
      status: AttendanceStatusExtension.fromString(markedStatus),
      checkInTime: checkInTime ?? DateTime.now(),
      checkOutTime: checkOutTime, // make sure your model has this field
      scannedBy: _storageService.getUser()?.id,
      scannedByName: _storageService.getUser()?.name ?? 'QR Scanner',
      createdAt: DateTime.now(),
    );

    todayAttendance.add(attendance);

    // Update list of all students
    final index = allStudents.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      allStudents[index] = updatedStudent;
    }

    // If we didn’t already show a message above based on action,
    // show a generic success here (can be removed if redundant).
    if (serverSuccess && (action != 'check_in' && action != 'check_out')) {
      _showAttendanceSuccess(
        student.name,
        markedStatus,
        serverSuccess,
        action: action,
      );
    } else if (!serverSuccess) {
      _showAttendanceSuccess(
        student.name,
        markedStatus,
        serverSuccess,
        action: action,
      );
    }
  }

  // void _showAttendanceSuccess(
  //   String studentName,
  //   String status,
  //   bool synced, {
  //   String action = 'check_in',
  // }) {
  //   String title;
  //   String message;
  //   Color bgColor;

  //   if (action == 'check_out') {
  //     // CHECK-OUT UI
  //     title = '✓ Checkout';
  //     message = '$studentName checked out successfully';
  //     bgColor = Colors.purple;
  //   } else {
  //     // CHECK-IN or others
  //     if (status == 'late') {
  //       title = '⏰ Late';
  //       message = '$studentName marked as LATE';
  //       bgColor = Colors.orange;
  //     } else if (status == 'present') {
  //       title = '✓ Present';
  //       message = '$studentName marked present';
  //       bgColor = Colors.green;
  //     } else {
  //       title = '✓ Marked';
  //       message = '$studentName marked as ${status.toUpperCase()}';
  //       bgColor = Colors.blue;
  //     }
  //   }

  //   if (!synced) {
  //     message += ' (pending sync)';
  //     bgColor = Colors.blue;
  //   }

  //   Get.snackbar(
  //     title,
  //     message,
  //     snackPosition: SnackPosition.TOP,
  //     backgroundColor: bgColor,
  //     colorText: Colors.white,
  //     duration: const Duration(seconds: 2),
  //     margin: const EdgeInsets.all(16),
  //     borderRadius: 12,
  //     icon: Icon(
  //       (action == 'check_out')
  //           ? Icons.exit_to_app
  //           : (status == 'late' ? Icons.access_time : Icons.check_circle),
  //       color: Colors.white,
  //     ),
  //   );
  // }

  void _showAttendanceSuccess(
  String studentName,
  String status,
  bool synced, {
  String action = 'check_in',
}) {
  // -----------------------------
  // Normalize inputs (VERY IMPORTANT)
  // -----------------------------
  final normalizedAction = action.trim().toLowerCase();
  final normalizedStatus = status.trim().toLowerCase();

  String title;
  String message;
  Color bgColor;
  IconData icon;

  // -----------------------------
  // CHECK-OUT (ALWAYS PRIORITY)
  // -----------------------------
  if (normalizedAction == 'check_out') {
    title = '✓ Checkout';
    message = '$studentName checked out successfully';
    bgColor = Colors.purple;
    icon = Icons.exit_to_app;
  }
  // -----------------------------
  // CHECK-IN
  // -----------------------------
  else {
    if (normalizedStatus == 'late') {
      title = '⏰ Late';
      message = '$studentName marked as LATE';
      bgColor = Colors.orange;
      icon = Icons.access_time;
    } else if (normalizedStatus == 'present') {
      title = '✓ Present';
      message = '$studentName marked present';
      bgColor = Colors.green;
      icon = Icons.check_circle;
    } else {
      title = '✓ Marked';
      message = '$studentName marked as ${normalizedStatus.toUpperCase()}';
      bgColor = Colors.blue;
      icon = Icons.info;
    }
  }

  // -----------------------------
  // OFFLINE / NOT SYNCED
  // -----------------------------
  if (!synced) {
    message += ' (pending sync)';
    bgColor = Colors.blueGrey;
  }

  // -----------------------------
  // SHOW SNACKBAR
  // -----------------------------
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: bgColor,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    icon: Icon(icon, color: Colors.white),
  );
}


  // ══════════════════════════════════════════════════════════
  // SCANNER CONTROLS
  // ══════════════════════════════════════════════════════════
  Future<void> toggleFlash() async {
    try {
      await scannerController?.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      _showError('Error', 'Failed to toggle flash');
    }
  }

  Future<void> toggleCamera() async {
    try {
      await scannerController?.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
    } catch (e) {
      _showError('Error', 'Failed to switch camera');
    }
  }

  void toggleScanning() {
    try {
      if (isScanning.value) {
        scannerController?.stop();
      } else {
        scannerController?.start();
      }
      isScanning.value = !isScanning.value;
    } catch (e) {
      _showError('Error', 'Failed to toggle scanning');
    }
  }

  void restartScanner() {
    scannerController?.dispose();
    initScanner();
    hasError.value = false;
    errorMessage.value = '';
  }

  // ══════════════════════════════════════════════════════════
  // CLEAR SCANNED STUDENTS
  // ══════════════════════════════════════════════════════════
  void clearScannedStudents() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Clear all scanned students?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Only clear locally scanned (not server synced)
              final localOnly = scannedStudents
                  .where((s) => !s.isMarkedOnServer)
                  .map((s) => s.id)
                  .toList();

              scannedStudents.removeWhere((s) => localOnly.contains(s.id));
              todayAttendance.removeWhere(
                (a) => localOnly.contains(a.studentId),
              );

              for (var id in localOnly) {
                final index = allStudents.indexWhere((s) => s.id == id);
                if (index != -1) {
                  allStudents[index] = allStudents[index].copyWith(
                    isPresent: false,
                    attendanceStatus: 'absent',
                  );
                }
              }

              Get.back();
              Get.snackbar(
                'Cleared',
                'Local attendance cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SAVE ATTENDANCE (Sync pending to server)
  // ══════════════════════════════════════════════════════════
  Future<void> saveAttendance() async {
    // Get students not yet synced
    final pendingStudents = scannedStudents
        .where((s) => !s.isMarkedOnServer)
        .toList();

    if (pendingStudents.isEmpty) {
      _showInfo('All Synced', 'All attendance is already saved.');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Save Attendance'),
        content: Text('Save ${pendingStudents.length} pending attendance?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _syncPendingAttendance(pendingStudents);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncPendingAttendance(
    List<StudentModel> pendingStudents,
  ) async {
    isSaving.value = true;

    // Show loading
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving attendance...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    int successCount = 0;
    int failedCount = 0;

    for (var student in pendingStudents) {
      try {
        final result = await AttendanceService.markAttendance(
          // token: _authToken!,
          studentId: student.id,
          status: 'present',
        );

        if (result['success'] == true) {
          successCount++;

          // Update student as synced
          final index = scannedStudents.indexWhere((s) => s.id == student.id);
          if (index != -1) {
            scannedStudents[index] = scannedStudents[index].copyWith(
              isMarkedOnServer: true,
            );
          }
        } else {
          failedCount++;
        }
      } catch (e) {
        failedCount++;
        // debugPrint('Sync error for ${student.id}: $e');
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    scannedStudents.refresh();
    isSaving.value = false;

    // Close loading
    Get.back();

    // Show result
    if (failedCount == 0) {
      Get.snackbar(
        'Success',
        'All $successCount attendance saved!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Partial Success',
        '$successCount saved, $failedCount failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // MANUAL ENTRY
  // ══════════════════════════════════════════════════════════
  void showManualEntry() {
    final rollController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Manual Entry'),
        content: TextField(
          controller: rollController,
          decoration: const InputDecoration(
            labelText: 'Roll Number',
            hintText: 'Enter roll number',
            prefixIcon: Icon(Icons.numbers),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
          onSubmitted: (value) => _processManualEntry(value, rollController),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () =>
                _processManualEntry(rollController.text, rollController),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _processManualEntry(
    String rollNumber,
    TextEditingController controller,
  ) async {
    final roll = rollNumber.trim();
    if (roll.isEmpty) return;

    // First try local search
    StudentModel? student = allStudents.firstWhereOrNull(
      (s) => s.rollNumber?.toLowerCase() == roll.toLowerCase(),
    );

    // If not found locally, try API search
    if (student == null) {
      try {
        final result = await StudentService.searchStudents(
          token: _authToken!,
          query: roll,
        );

        if (result['success'] == true && result['data'] != null) {
          final List<dynamic> students = result['data'];
          if (students.isNotEmpty) {
            student = StudentModel.fromJson(students.first);
            // Add to local list
            if (!allStudents.any((s) => s.id == student!.id)) {
              allStudents.add(student);
            }
          }
        }
      } catch (e) {
        // debugPrint('Search error: $e');
      }
    }

    if (student == null) {
      Get.back();
      _showError('Not Found', 'No student with roll: $roll');
      return;
    }

    final alreadyScanned = scannedStudents.any((s) => s.id == student!.id);
    if (alreadyScanned) {
      Get.back();
      _showWarning('Already Marked', '${student.name} is already present.');
      return;
    }

    Get.back();
    await markAttendance(student);
  }

  // ══════════════════════════════════════════════════════════
  // REMOVE STUDENT
  // ══════════════════════════════════════════════════════════
  void removeStudent(String studentId) {
    final student = scannedStudents.firstWhereOrNull((s) => s.id == studentId);

    if (student != null && student.isMarkedOnServer) {
      _showWarning('Cannot Remove', 'Already synced to server.');
      return;
    }

    scannedStudents.removeWhere((s) => s.id == studentId);
    todayAttendance.removeWhere((a) => a.studentId == studentId);

    final index = allStudents.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      allStudents[index] = allStudents[index].copyWith(
        isPresent: false,
        attendanceStatus: 'absent',
      );
    }

    _showInfo('Removed', 'Student removed from list.');
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════
  Future<void> _vibrate() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      // Ignore vibration errors
    }
  }

  void _showError(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _showWarning(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.warningColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    }
  }

  void _showInfo(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.info, color: Colors.white),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // STATISTICS
  // ══════════════════════════════════════════════════════════
  Map<String, int> getStats() {
    return {
      'total': totalStudents,
      'scanned': scannedStudents.length,
      'synced': scannedStudents.where((s) => s.isMarkedOnServer).length,
      'pending': scannedStudents.where((s) => !s.isMarkedOnServer).length,
    };
  }

  int get syncedCount =>
      scannedStudents.where((s) => s.isMarkedOnServer).length;
  int get pendingCount =>
      scannedStudents.where((s) => !s.isMarkedOnServer).length;
}

class AttendanceStatusExtension {
  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }
}
