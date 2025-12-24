// lib/controllers/teacher_qr_scanner_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import '../models/teacher_model.dart';
import '../models/teacher_attendance_model.dart';
import '../services/teacher_attendance_service.dart';
import '../services/storage_service.dart';
import '../services/teacher_service.dart';
import '../app/theme/app_theme.dart';
import '../app/utils/teacher_qr_helper.dart';

class TeacherQrScannerController extends GetxController {
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
  final isLoadingTeachers = false.obs;
  final teachersLoadError = ''.obs;

  // ══════════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════════
  final scannedTeachers = <TeacherModel>[].obs;
  final todayAttendance = <TeacherAttendanceModel>[].obs;
  final allTeachers = <TeacherModel>[].obs;
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
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  int get presentCount => scannedTeachers.length;
  int get totalTeachers => allTeachers.length;

  double get attendancePercentage =>
      totalTeachers > 0 ? (presentCount / totalTeachers) * 100 : 0;

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

    // Load teachers from API
    await loadTeachersFromAPI();
    await fetchTodayAttendance();

    // Fallback to mock data if not authenticated
    _loadMockTeachers();
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
  // LOAD TEACHER FROM API
  // ══════════════════════════════════════════════════════════
  Future<void> loadTeachersFromAPI() async {
    isLoadingTeachers.value = true;
    teachersLoadError.value = '';

    try {
      // debugPrint('Fetching teachers from API...');

      final result = await TeacherService.getAllteachers();

      // debugPrint('Teachers API Response: success=${result['success']}');

      if (result['success'] == true) {
        // ✅ Teachers are already parsed as List<TeacherModel>
        final List<TeacherModel> teachers = result['teachers'] ?? [];

        allTeachers.value = teachers;

        // debugPrint('✓ Loaded ${allTeachers.length} teachers from API');
      } else {
        teachersLoadError.value =
            result['message'] ?? 'Failed to load teachers';
        // debugPrint('✗ Failed to load teachers: ${result['message']}');

        // Fallback to mock data
        _loadMockTeachers();
      }
    } catch (e, stackTrace) {
      // debugPrint('✗ Error loading teachers: $e');
      // debugPrint('Stack trace: $stackTrace');
      // teachersLoadError.value = 'Error: $e';

      // Fallback to mock data
      _loadMockTeachers();
    } finally {
      isLoadingTeachers.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // REFRESH TEACHERS
  // ══════════════════════════════════════════════════════════
  Future<void> refreshTeachers() async {
    await loadTeachersFromAPI();

    if (teachersLoadError.value.isEmpty) {
      _showInfo('Refreshed', 'Teacher list updated');
    } else {
      _showError('Error', teachersLoadError.value);
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD MOCK TEACHERS (Fallback)
  // ══════════════════════════════════════════════════════════
  void _loadMockTeachers() {
    // debugPrint('Loading mock teachers as fallback...');

    allTeachers.value = List.generate(
      50,
      (index) => TeacherModel(
        id: 'STU${index + 1}',
        roleId: 'teacher',
        gender: index % 2 == 0 ? 'Male' : 'Female',
        firstName: 'Teacher',
        lastName: '${index + 1}',
        // roleNumber: '${2024}${(index + 1).toString().padLeft(3, '0')}',
        email: 'teachers${index + 1}@school.com',
        mobileCode: '+91',
        mobileNumber: '98765${(index + 1).toString().padLeft(5, '0')}',
        mobileNumberVerified: true,
        status: 'Active',
        isOtpNeeded: false,
      ),
    );

    // debugPrint('Loaded ${allTeachers.length} mock teachers');
  }

  // ══════════════════════════════════════════════════════════
  // FIND Teacher BY ID (API or Local)
  // ══════════════════════════════════════════════════════════
  Future<TeacherModel?> findTeacherById(String teacherId) async {
    // First, try to find in local list
    TeacherModel? teacher = allTeachers.firstWhereOrNull(
      (s) => s.id == teacherId,
    );

    if (teacher != null) {
      // debugPrint('✓ Found teacher locally: ${teacher.name}');
      return teacher;
    }

    // If not found locally, try API
    try {
      // debugPrint('Teacher not found locally, fetching from API...');

      final result = await TeacherService.getTeacherById(teacherId: teacherId);

      // debugPrint('API Result: $result');

      if (result['success'] == true && result['teacher'] != null) {
        // ✅ teacher is already parsed as TeacherModel in the service
        teacher = result['teacher'] as TeacherModel;

        // Add to local list if not already exists
        if (!allTeachers.any((s) => s.id == teacher!.id)) {
          allTeachers.add(teacher);
        }

        // debugPrint('✓ Found teacher from API: ${teacher.name}');
        return teacher;
      } else {
        // debugPrint('✗ Teacher not found: ${result['message']}');
      }
    } catch (e) {
      // debugPrint('❌ Error fetching teacher by ID: $e');
    }

    return null;
  }

  // ══════════════════════════════════════════════════════════
  // FETCH TODAY'S ATTENDANCE FROM SERVER
  // ══════════════════════════════════════════════════════════
  Future<void> fetchTodayAttendance() async {
    try {
      final result = await TeacherAttendanceService.getTodayAttendance(
        // token: _authToken!,
      );

      if (result['success'] == true) {
        todayAttendance.value = result['attendance'] ?? [];

        // Mark already attended teachers
        for (var attendance in todayAttendance) {
          final teacher = allTeachers.firstWhereOrNull(
            (s) => s.id == attendance.teacherId,
          );
          if (teacher != null && !scannedTeachers.contains(teacher)) {
            final updatedTeacher = teacher.copyWith(
              isPresent: true,
              isMarkedOnServer: true,
              attendanceStatus: attendance.status.name,
            );
            scannedTeachers.add(updatedTeacher);
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
      final qrData = TeacherQRHelper.parseQRCode(code);
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

      final teacherId = qrData['id'] as String;

      // ✅ Find teacher using API-aware method
      final teacher = await findTeacherById(teacherId);

      if (teacher == null) {
        _showError('Not Found', 'No teacher found with ID: $teacherId');
        isProcessing.value = false;
        return;
      }

      // Check if already scanned
      final alreadyScanned = scannedTeachers.any((s) => s.id == teacher.id);
      if (alreadyScanned) {
        _showWarning(
          'Already Marked',
          '${teacher.name} is already marked present.',
        );
        isProcessing.value = false;
        return;
      }

      // Mark attendance
      await markAttendance(teacher);
    } catch (e) {
      _showError('Error', 'Failed to process QR code: $e');
      // debugPrint('QR process error: $e');
    }

    isProcessing.value = false;
  }

  Future<void> markAttendance(TeacherModel teacher) async {
    _vibrate();

    bool serverSuccess = false;
    String markedStatus = 'present';
    String? attendanceId;
    DateTime? checkInTime;
    DateTime? checkOutTime;
    String action = 'check_in';
    bool shouldSaveLocally = true;
    bool messageShown = false;

    try {
      final result = await TeacherAttendanceService.markAttendance(
        teacherId: teacher.id,
      );

      final bool success = result['success'] == true;
      action = result['action'] ?? 'check_in';
      final data = result['data'] as Map<String, dynamic>?;

      if (success) {
        serverSuccess = true;

        // Extract data from nested 'data' object
        markedStatus = data?['status'] ?? 'present';
        attendanceId = data?['_id'];

        // Parse times (API uses snake_case)
        final checkInTimeStr = data?['check_in_time'];
        final checkOutTimeStr = data?['check_out_time'];

        if (checkInTimeStr != null) {
          checkInTime = DateTime.tryParse(checkInTimeStr);
        }
        if (checkOutTimeStr != null) {
          checkOutTime = DateTime.tryParse(checkOutTimeStr);
        }

        // Handle specific actions
        switch (action) {
          case 'check_in':
          case 'check_out':
            _showAttendanceSuccess(
              teacher.name,
              markedStatus,
              serverSuccess,
              action: action,
            );
            messageShown = true;
            break;

          case 'already_checked_out':
            _showWarning(
              'Already Checked Out',
              '${teacher.name} is already checked out for today.',
            );
            shouldSaveLocally = false; // Don't duplicate local record
            return;

          case 'too_early_for_checkout':
            _showWarning(
              'Too Early',
              result['message'] ?? 'Cannot checkout yet.',
            );
            shouldSaveLocally = false;
            return;

          default:
            _showAttendanceSuccess(
              teacher.name,
              markedStatus,
              serverSuccess,
              action: action,
            );
            messageShown = true;
        }
      } else {
        // Server returned success: false
        if (result['alreadyMarked'] == true) {
          _showWarning('Already Marked', '${teacher.name} was already marked.');
          return;
        }

        _showWarning(
          'Error',
          result['message'] ?? 'Failed to mark attendance.',
        );
        messageShown = true;
        // Continue to save locally as offline backup
      }
    } catch (e) {
      _showWarning('Network Error', 'Saving offline: ${e.toString()}');
      messageShown = true;
      // Continue to save locally
    }

    // -------------------------
    // CREATE LOCAL RECORD
    // -------------------------
    if (!shouldSaveLocally) return;

    final updatedTeacher = teacher.copyWith(
      isPresent: true,
      isMarkedOnServer: serverSuccess,
      attendanceStatus: markedStatus,
    );

    scannedTeachers.add(updatedTeacher);

    final attendance = TeacherAttendanceModel(
      id: attendanceId ?? 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
      teacherId: teacher.id,
      teacherName: teacher.name,
      date: DateTime.now(),
      status: AttendanceStatusExtension.fromString(markedStatus),
      checkInTime: checkInTime ?? DateTime.now(),
      checkOutTime: checkOutTime,
      scannedBy: _storageService.getUser()?.id,
      scannedByName: _storageService.getUser()?.name ?? 'QR Scanner',
      createdAt: DateTime.now(),
      // isSynced: serverSuccess, // Track if synced to server
    );

    todayAttendance.add(attendance);

    // Update allTeachers list
    final index = allTeachers.indexWhere((s) => s.id == teacher.id);
    if (index != -1) {
      allTeachers[index] = updatedTeacher;
    }

    // Only show message if not already shown
    if (!messageShown) {
      _showAttendanceSuccess(
        teacher.name,
        markedStatus,
        serverSuccess,
        action: action,
      );
    }
  }

  // Future<void> markAttendance(TeacherModel teacher) async {
  //   _vibrate();

  //   bool serverSuccess = false;
  //   String markedStatus = 'present';
  //   String? attendanceId;
  //   DateTime? checkInTime;
  //   DateTime? checkOutTime;
  //   String action = 'check_in'; // default

  //   try {
  //     final result = await TeacherAttendanceService.markAttendance(
  //       teacherId: teacher.id,
  //     );

  //     final bool success = result['success'] == true;
  //     action = result['action'] ?? 'check_in';

  //     if (success) {
  //       serverSuccess = true;

  //       // status can be at the root or in data
  //       markedStatus =
  //           result['status'] ?? result['data']?['status'] ?? 'present';

  //       // attendance id
  //       attendanceId =
  //           result['attendanceId'] ??
  //           result['data']?['_id'] ??
  //           result['data']?['attendance_id'];

  //       // times
  //       final checkInTimeStr =
  //           result['checkInTime'] ?? result['data']?['check_in_time'];
  //       final checkOutTimeStr =
  //           result['checkOutTime'] ?? result['data']?['check_out_time'];

  //       if (checkInTimeStr != null) {
  //         checkInTime = DateTime.tryParse(checkInTimeStr);
  //       }
  //       if (checkOutTimeStr != null) {
  //         checkOutTime = DateTime.tryParse(checkOutTimeStr);
  //       }

  //       // Handle specific actions from backend
  //       if (action == 'check_in') {
  //         // normal first scan
  //         _showAttendanceSuccess(
  //           teacher.name,
  //           markedStatus,
  //           serverSuccess,
  //           action: 'check_in',
  //         );
  //       } else if (action == 'check_out') {
  //         // successful checkout
  //         _showAttendanceSuccess(
  //           teacher.name,
  //           markedStatus,
  //           serverSuccess,
  //           action: 'check_out',
  //         );
  //       } else if (action == 'already_checked_out') {
  //         _showWarning(
  //           'Already Checked Out',
  //           '${teacher.name} is already checked out for today.',
  //         );
  //         // Optionally, still record locally or just return
  //         return;
  //       } else if (action == 'too_early_for_checkout') {
  //         _showWarning(
  //           'Too Early',
  //           result['message'] ?? 'Cannot checkout yet.',
  //         );
  //         return;
  //       } else {
  //         // fallback
  //         _showAttendanceSuccess(
  //           teacher.name,
  //           markedStatus,
  //           serverSuccess,
  //           action: action,
  //         );
  //       }
  //     } else {
  //       // Handle non-success from server
  //       if (result['alreadyMarked'] == true) {
  //         // Old behavior if your backend still uses this flag somewhere
  //         _showWarning('Already Marked', '${teacher.name} was already marked.');
  //         return;
  //       }

  //       // Some error from server
  //       _showWarning(
  //         'Error',
  //         result['message'] ?? 'Failed to mark attendance.',
  //       );
  //       // You can decide whether to still add locally or not
  //     }
  //   } catch (e) {
  //     // API Error (network, etc.)
  //     _showWarning('Teacher Network Error',e.toString());
  //     // You keep serverSuccess = false and fall through to local save
  //   }

  //   // -------------------------
  //   // CREATE LOCAL RECORD
  //   // -------------------------

  //   // For check-out, you might want different handling, but
  //   // here I always create/update a local attendance record.

  //   final updatedTeacher = teacher.copyWith(
  //     isPresent: true,
  //     isMarkedOnServer: serverSuccess,
  //     attendanceStatus: markedStatus,
  //   );

  //   scannedTeachers.add(updatedTeacher);

  //   final attendance = TeacherAttendanceModel(
  //     id: attendanceId ?? 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
  //     teacherId: teacher.id,
  //     teacherName: teacher.name,
  //     // teacherRollNumber: teacher.rollNumber,
  //     // teacherClassName: teacher.className,
  //     // teacherSection: teacher.section,
  //     date: DateTime.now(),
  //     status: AttendanceStatusExtension.fromString(markedStatus),
  //     checkInTime: checkInTime ?? DateTime.now(),
  //     checkOutTime: checkOutTime, // make sure your model has this field
  //     scannedBy: _storageService.getUser()?.id,
  //     scannedByName: _storageService.getUser()?.name ?? 'QR Scanner',
  //     createdAt: DateTime.now(),
  //   );

  //   todayAttendance.add(attendance);

  //   // Update list of all teachers
  //   final index = allTeachers.indexWhere((s) => s.id == teacher.id);
  //   if (index != -1) {
  //     allTeachers[index] = updatedTeacher;
  //   }

  //   // If we didn’t already show a message above based on action,
  //   // show a generic success here (can be removed if redundant).
  //   if (serverSuccess && (action != 'check_in' && action != 'check_out')) {
  //     _showAttendanceSuccess(
  //       teacher.name,
  //       markedStatus,
  //       serverSuccess,
  //       action: action,
  //     );
  //   } else if (!serverSuccess) {
  //     _showAttendanceSuccess(
  //       teacher.name,
  //       markedStatus,
  //       serverSuccess,
  //       action: action,
  //     );
  //   }
  // }

  void _showAttendanceSuccess(
    String teacherName,
    String status,
    bool synced, {
    String action = 'check_in',
  }) {
    final normalizedAction = action.trim().toLowerCase();
    final normalizedStatus = status.trim().toLowerCase();
    String title;
    String message;
    Color bgColor;
    IconData icon;

    if (normalizedAction == 'check_out') {
      title = '✓ Checkout';
      message = '$teacherName checked out successfully';
      bgColor = Colors.purple;
      icon = Icons.exit_to_app;
    }
    // -----------------------------
    // CHECK-IN
    // -----------------------------
    else {
      if (normalizedStatus == 'late') {
        title = '⏰ Late';
        message = '$teacherName marked as LATE';
        bgColor = Colors.orange;
        icon = Icons.access_time;
      } else if (normalizedStatus == 'present') {
        title = '✓ Present';
        message = '$teacherName marked present';
        bgColor = Colors.green;
        icon = Icons.check_circle;
      } else {
        title = '✓ Marked';
        message = '$teacherName marked as ${normalizedStatus.toUpperCase()}';
        bgColor = Colors.blue;
        icon = Icons.info;
      }
    }

    if (!synced) {
      message += ' (pending sync)';
      bgColor = Colors.blue;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(
        (action == 'check_out')
            ? Icons.exit_to_app
            : (status == 'late' ? Icons.access_time : Icons.check_circle),
        color: Colors.white,
      ),
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
  // CLEAR SCANNED TEACHERS
  // ══════════════════════════════════════════════════════════
  void clearScannedTeachers() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Clear all scanned teachers?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Only clear locally scanned (not server synced)
              final localOnly = scannedTeachers
                  .where((s) => !s.isMarkedOnServer)
                  .map((s) => s.id)
                  .toList();

              scannedTeachers.removeWhere((s) => localOnly.contains(s.id));
              todayAttendance.removeWhere(
                (a) => localOnly.contains(a.teacherId),
              );

              for (var id in localOnly) {
                final index = allTeachers.indexWhere((s) => s.id == id);
                if (index != -1) {
                  allTeachers[index] = allTeachers[index].copyWith(
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
    // Get teachers not yet synced
    final pendingTeachers = scannedTeachers
        .where((s) => !s.isMarkedOnServer)
        .toList();

    if (pendingTeachers.isEmpty) {
      _showInfo('All Synced', 'All attendance is already saved.');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Save Attendance'),
        content: Text('Save ${pendingTeachers.length} pending attendance?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _syncPendingAttendance(pendingTeachers);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncPendingAttendance(
    List<TeacherModel> pendingTeachers,
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

    for (var teacher in pendingTeachers) {
      try {
        final result = await TeacherAttendanceService.markAttendance(
          // token: _authToken!,
          teacherId: teacher.id,
          status: 'present',
        );

        if (result['success'] == true) {
          successCount++;

          // Update teacher as synced
          final index = scannedTeachers.indexWhere((s) => s.id == teacher.id);
          if (index != -1) {
            scannedTeachers[index] = scannedTeachers[index].copyWith(
              isMarkedOnServer: true,
            );
          }
        } else {
          failedCount++;
        }
      } catch (e) {
        failedCount++;
        // debugPrint('Sync error for ${teacher.id}: $e');
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    scannedTeachers.refresh();
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
  // REMOVE teacher
  // ══════════════════════════════════════════════════════════
  void removeTeacher(String teacherId) {
    final teacher = scannedTeachers.firstWhereOrNull((s) => s.id == teacherId);

    if (teacher != null && teacher.isMarkedOnServer) {
      _showWarning('Cannot Remove', 'Already synced to server.');
      return;
    }

    scannedTeachers.removeWhere((s) => s.id == teacherId);
    todayAttendance.removeWhere((a) => a.teacherId == teacherId);

    final index = allTeachers.indexWhere((s) => s.id == teacherId);
    if (index != -1) {
      allTeachers[index] = allTeachers[index].copyWith(
        isPresent: false,
        attendanceStatus: 'absent',
      );
    }

    _showInfo('Removed', 'Teacher removed from list.');
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
      'total': totalTeachers,
      'scanned': scannedTeachers.length,
      'synced': scannedTeachers.where((s) => s.isMarkedOnServer).length,
      'pending': scannedTeachers.where((s) => !s.isMarkedOnServer).length,
    };
  }

  int get syncedCount =>
      scannedTeachers.where((s) => s.isMarkedOnServer).length;
  int get pendingCount =>
      scannedTeachers.where((s) => !s.isMarkedOnServer).length;
}

class AttendanceStatusExtension {
  static TeacherAttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return TeacherAttendanceStatus.present;
      case 'absent':
        return TeacherAttendanceStatus.absent;
      case 'late':
        return TeacherAttendanceStatus.late;
      default:
        return TeacherAttendanceStatus.absent;
    }
  }
}
