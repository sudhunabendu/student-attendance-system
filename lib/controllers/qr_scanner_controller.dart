// lib/controllers/qr_scanner_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:vibration/vibration.dart';
// import '../models/student_model.dart';
// import '../models/attendance_model.dart';
// import '../app/theme/app_theme.dart';

// class QRScannerController extends GetxController {
//   // Scanner state
//   final isScanning = true.obs;
//   final isFlashOn = false.obs;
//   final isFrontCamera = false.obs;
//   final isProcessing = false.obs;
//   final hasError = false.obs;
//   final errorMessage = ''.obs;
  
//   // Scanned students
//   final scannedStudents = <StudentModel>[].obs;
//   final todayAttendance = <AttendanceModel>[].obs;
  
//   // Selected date
//   final selectedDate = DateTime.now().obs;
  
//   // All students (mock data)
//   final allStudents = <StudentModel>[].obs;
  
//   // Scanner controller
//   MobileScannerController? scannerController;
  
//   // Last scanned code (to prevent duplicates)
//   String? lastScannedCode;
//   DateTime? lastScanTime;

//   @override
//   void onInit() {
//     super.onInit();
//     loadStudents();
//     initScanner();
//   }

//   @override
//   void onClose() {
//     scannerController?.dispose();
//     super.onClose();
//   }

//   // Initialize scanner
//   void initScanner() {
//     try {
//       scannerController = MobileScannerController(
//         facing: CameraFacing.back,
//         torchEnabled: false,
//         detectionSpeed: DetectionSpeed.normal,
//         detectionTimeoutMs: 1000,
//       );
//       hasError.value = false;
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = 'Failed to initialize camera: $e';
//     }
//   }

//   // Load mock students
//   void loadStudents() {
//     allStudents.value = List.generate(
//       50,
//       (index) => StudentModel(
//         id: 'STU${(index + 1).toString().padLeft(3, '0')}',
//         name: 'Student ${index + 1}',
//         firstName: 'First${index + 1}',
//         lastName: 'Last${index + 1}',
//         rollNumber: '2024${(index + 1).toString().padLeft(3, '0')}',
//         className: ['10th', '11th', '12th'][index % 3],
//         section: ['A', 'B', 'C', 'D'][index % 4],
//         isPresent: false,
//       ),
//     );
//   }

//   // Handle barcode detection
//   void onBarcodeDetected(BarcodeCapture capture) {
//     final List<Barcode> barcodes = capture.barcodes;
    
//     for (final barcode in barcodes) {
//       if (barcode.rawValue != null && !isProcessing.value) {
//         processQRCode(barcode.rawValue!);
//         break;
//       }
//     }
//   }

//   // Handle scanner error
//   void onScannerError(MobileScannerException error, StackTrace? stackTrace) {
//     hasError.value = true;
//     errorMessage.value = 'Camera error: ${error.errorCode.name}';
//   }

//   // Process scanned QR code
//   Future<void> processQRCode(String code) async {
//     // Prevent duplicate scans within 2 seconds
//     final now = DateTime.now();
//     if (lastScannedCode == code && 
//         lastScanTime != null && 
//         now.difference(lastScanTime!).inSeconds < 2) {
//       return;
//     }
    
//     lastScannedCode = code;
//     lastScanTime = now;
//     isProcessing.value = true;
    
//     try {
//       // Parse QR code data
//       final qrData = StudentModel.parseQRData(code);
      
//       if (qrData == null) {
//         _showError('Invalid QR Code', 'This QR code is not valid for attendance.');
//         isProcessing.value = false;
//         return;
//       }
      
//       // Find student
//       final student = allStudents.firstWhereOrNull(
//         (s) => s.id == qrData.id || s.rollNumber == qrData.rollNumber,
//       );
      
//       if (student == null) {
//         _showError('Student Not Found', 'No student found with this QR code.');
//         isProcessing.value = false;
//         return;
//       }
      
//       // Check if already scanned today
//       final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
      
//       if (alreadyScanned) {
//         _showWarning('Already Marked', '${student.name} is already marked present today.');
//         isProcessing.value = false;
//         return;
//       }
      
//       // Mark attendance
//       await markAttendance(student);
      
//     } catch (e) {
//       _showError('Error', 'Failed to process QR code: $e');
//     }
    
//     isProcessing.value = false;
//   }

//   // Mark attendance for student
//   Future<void> markAttendance(StudentModel student) async {
//     // Vibrate for feedback
//     try {
//       if (await Vibration.hasVibrator() ?? false) {
//         Vibration.vibrate(duration: 200);
//       }
//     } catch (e) {
//       // Ignore vibration errors
//     }
    
//     // Update student status
//     final updatedStudent = student.copyWith(
//       isPresent: true,
//       attendanceStatus: 'present',
//     );
    
//     // Add to scanned list
//     scannedStudents.add(updatedStudent);
    
//     // Create attendance record
//     final attendance = AttendanceModel(
//       id: 'ATT${DateTime.now().millisecondsSinceEpoch}',
//       studentId: student.id,
//       studentName: student.name,
//       studentRollNumber: student.rollNumber,
//       studentClass: student.className,
//       studentSection: student.section,
//       date: _formatDate(selectedDate.value),
//       status: AttendanceStatus.present,
//       markedBy: 'QR_SCANNER',
//       markedByName: 'Auto - QR Scan',
//       markedAt: DateTime.now(),
//       checkInTime: TimeOfDay.now(),
//     );
    
//     todayAttendance.add(attendance);
    
//     // Update in all students list
//     final index = allStudents.indexWhere((s) => s.id == student.id);
//     if (index != -1) {
//       allStudents[index] = updatedStudent;
//     }
    
//     // Show success message
//     _showSuccess(student.name);
//   }

//   // Toggle flash
//   Future<void> toggleFlash() async {
//     try {
//       await scannerController?.toggleTorch();
//       isFlashOn.value = !isFlashOn.value;
//     } catch (e) {
//       _showError('Error', 'Failed to toggle flash');
//     }
//   }

//   // Toggle camera
//   Future<void> toggleCamera() async {
//     try {
//       await scannerController?.switchCamera();
//       isFrontCamera.value = !isFrontCamera.value;
//     } catch (e) {
//       _showError('Error', 'Failed to switch camera');
//     }
//   }

//   // Pause/Resume scanning
//   void toggleScanning() {
//     try {
//       if (isScanning.value) {
//         scannerController?.stop();
//       } else {
//         scannerController?.start();
//       }
//       isScanning.value = !isScanning.value;
//     } catch (e) {
//       _showError('Error', 'Failed to toggle scanning');
//     }
//   }

//   // Restart scanner
//   void restartScanner() {
//     scannerController?.dispose();
//     initScanner();
//     hasError.value = false;
//   }

//   // Clear today's scanned students
//   void clearScannedStudents() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Clear All'),
//         content: const Text('Are you sure you want to clear all scanned students?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               scannedStudents.clear();
//               todayAttendance.clear();
              
//               for (int i = 0; i < allStudents.length; i++) {
//                 allStudents[i] = allStudents[i].copyWith(
//                   isPresent: false,
//                   attendanceStatus: 'absent',
//                 );
//               }
              
//               Get.back();
//               Get.snackbar(
//                 'Cleared',
//                 'All scanned students have been cleared.',
//                 snackPosition: SnackPosition.BOTTOM,
//                 backgroundColor: Colors.orange,
//                 colorText: Colors.white,
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Save attendance
//   Future<void> saveAttendance() async {
//     if (scannedStudents.isEmpty) {
//       _showError('No Students', 'Please scan at least one student QR code.');
//       return;
//     }
    
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Save Attendance'),
//         content: Text('Save attendance for ${scannedStudents.length} students?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
              
//               Get.dialog(
//                 const Center(
//                   child: Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                 ),
//                 barrierDismissible: false,
//               );
              
//               await Future.delayed(const Duration(seconds: 2));
              
//               Get.back();
              
//               Get.snackbar(
//                 'Success',
//                 'Attendance saved for ${scannedStudents.length} students!',
//                 snackPosition: SnackPosition.BOTTOM,
//                 backgroundColor: AppTheme.successColor,
//                 colorText: Colors.white,
//                 duration: const Duration(seconds: 3),
//               );
              
//               Get.back();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Manual entry
//   void showManualEntry() {
//     final TextEditingController rollController = TextEditingController();
    
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Manual Entry'),
//         content: TextField(
//           controller: rollController,
//           decoration: const InputDecoration(
//             labelText: 'Roll Number',
//             hintText: 'Enter student roll number',
//             prefixIcon: Icon(Icons.numbers),
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.text,
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final rollNumber = rollController.text.trim();
//               if (rollNumber.isEmpty) return;
              
//               final student = allStudents.firstWhereOrNull(
//                 (s) => s.rollNumber.toLowerCase() == rollNumber.toLowerCase(),
//               );
              
//               if (student == null) {
//                 Get.back();
//                 _showError('Not Found', 'No student found with roll number: $rollNumber');
//                 return;
//               }
              
//               final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
//               if (alreadyScanned) {
//                 Get.back();
//                 _showWarning('Already Marked', '${student.name} is already marked present.');
//                 return;
//               }
              
//               Get.back();
//               markAttendance(student);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Remove student from scanned list
//   void removeStudent(String studentId) {
//     scannedStudents.removeWhere((s) => s.id == studentId);
//     todayAttendance.removeWhere((a) => a.studentId == studentId);
    
//     final index = allStudents.indexWhere((s) => s.id == studentId);
//     if (index != -1) {
//       allStudents[index] = allStudents[index].copyWith(
//         isPresent: false,
//         attendanceStatus: 'absent',
//       );
//     }
//   }

//   // Helper methods
//   String _formatDate(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   void _showSuccess(String studentName) {
//     Get.snackbar(
//       '✓ Present',
//       '$studentName marked present!',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: AppTheme.successColor,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//       margin: const EdgeInsets.all(16),
//       borderRadius: 12,
//       icon: const Icon(Icons.check_circle, color: Colors.white),
//     );
//   }

//   void _showError(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: AppTheme.errorColor,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//       margin: const EdgeInsets.all(16),
//       borderRadius: 12,
//       icon: const Icon(Icons.error, color: Colors.white),
//     );
//   }

//   void _showWarning(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: AppTheme.warningColor,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//       margin: const EdgeInsets.all(16),
//       borderRadius: 12,
//       icon: const Icon(Icons.warning, color: Colors.white),
//     );
//   }

//   // Stats
//   int get presentCount => scannedStudents.length;
//   int get totalStudents => allStudents.length;
//   double get attendancePercentage => 
//       totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
// }

// lib/controllers/qr_scanner_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../services/storage_service.dart';
import '../app/theme/app_theme.dart';

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
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

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
    loadStudents();
    initScanner();
    if (isAuthenticated) {
      await fetchTodayAttendance();
    }
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
      debugPrint('Scanner init error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOAD STUDENTS (Mock or API)
  // ══════════════════════════════════════════════════════════
  void loadStudents() {
    // TODO: Replace with API call
    allStudents.value = List.generate(
      50,
      (index) => StudentModel(
        id: 'STU${(index + 1).toString().padLeft(3, '0')}',
        firstName: 'First${index + 1}',
        lastName: 'Last${index + 1}',
        rollNumber: '2024${(index + 1).toString().padLeft(3, '0')}',
        className: ['10th', '11th', '12th'][index % 3],
        section: ['A', 'B', 'C', 'D'][index % 4],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FETCH TODAY'S ATTENDANCE FROM SERVER
  // ══════════════════════════════════════════════════════════
  Future<void> fetchTodayAttendance() async {
    if (!isAuthenticated) return;

    try {
      final result = await AttendanceService.getTodayAttendance(
        token: _authToken!,
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
              attendanceStatus: attendance.status.value,
            );
            scannedStudents.add(updatedStudent);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching today attendance: $e');
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
    debugPrint('Scanner error: ${error.errorCode.name}');
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
      // Parse QR code data
      final qrData = StudentModel.parseQRData(code);
      print('Scanned QR Data: $qrData');
      if (qrData == null) {
        _showError('Invalid QR Code', 'This QR code is not valid.');
        isProcessing.value = false;
        return;
      }

      // Check QR validity (optional - 24 hour check)
      if (!qrData.isValid) {
        _showWarning('Expired QR', 'This QR code has expired.');
        isProcessing.value = false;
        return;
      }

      // Find student
      final student = allStudents.firstWhereOrNull(
        (s) => s.id == qrData.id || s.rollNumber == qrData.rollNumber,
      );

      if (student == null) {
        _showError('Not Found', 'No student found with this QR code.');
        isProcessing.value = false;
        return;
      }

      // Check if already scanned
      final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
      if (alreadyScanned) {
        _showWarning('Already Marked', '${student.name} is already present.');
        isProcessing.value = false;
        return;
      }

      // Mark attendance
      await markAttendance(student);
    } catch (e) {
      _showError('Error', 'Failed to process QR code: $e');
      debugPrint('QR process error: $e');
    }

    isProcessing.value = false;
  }

  // ══════════════════════════════════════════════════════════
  // MARK ATTENDANCE
  // ══════════════════════════════════════════════════════════
  // Future<void> markAttendance(StudentModel student) async {
  //   // Vibrate feedback
  //   _vibrate();

  //   // Call API if authenticated
  //   bool serverSuccess = false;
  //   if (isAuthenticated) {
  //     final result = await AttendanceService.markAttendance(
  //       token: _authToken!,
  //       studentId: student.id,
  //       status: 'present',
  //     );

  //     serverSuccess = result['success'] == true;

  //     if (!serverSuccess) {
  //       // Check if already marked on server
  //       if (result['alreadyMarked'] == true) {
  //         _showWarning('Already Marked', '${student.name} was already marked.');
  //         return;
  //       }
  //       // Show error but still add locally
  //       debugPrint('Server error: ${result['message']}');
  //     }
  //   }

  //   // Update student
  //   final updatedStudent = student.copyWith(
  //     isPresent: true,
  //     isMarkedOnServer: serverSuccess,
  //     attendanceStatus: 'present',
  //   );

  //   // Add to scanned list
  //   scannedStudents.add(updatedStudent);

  //   // Create local attendance record
  //   final attendance = AttendanceModel(
  //     id: 'ATT${DateTime.now().millisecondsSinceEpoch}',
  //     studentId: student.id,
  //     studentName: student.name,
  //     studentRollNumber: student.rollNumber,
  //     studentClassName: student.className,
  //     studentSection: student.section,
  //     date: selectedDate.value,
  //     status: AttendanceStatus.present,
  //     scannedBy: _storageService.getUser()?.id,
  //     scannedByName: _storageService.getUser()?.name ?? 'QR Scanner',
  //     createdAt: DateTime.now(),
  //     checkInTime: DateTime.now(),
  //   );

  //   todayAttendance.add(attendance);

  //   // Update in all students list
  //   final index = allStudents.indexWhere((s) => s.id == student.id);
  //   if (index != -1) {
  //     allStudents[index] = updatedStudent;
  //   }

  //   // Show success
  //   _showSuccess(student.name, serverSuccess);
  // }
  Future<void> markAttendance(StudentModel student) async {
  _vibrate();

  bool serverSuccess = false;
  String markedStatus = 'present';
  String? attendanceId;
  DateTime? checkInTime;

  if (isAuthenticated) {
    try {
      final result = await AttendanceService.markAttendance(
        token: _authToken!,
        studentId: student.id,
      );

      debugPrint('Attendance API Response: $result');

      if (result['success'] == true) {
        serverSuccess = true;
        
        // Get the actual status from server response (could be 'late')
        markedStatus = result['status'] ?? result['data']?['status'] ?? 'present';
        attendanceId = result['attendanceId'] ?? result['data']?['attendance_id'];
        
        // Parse check-in time
        final checkInTimeStr = result['checkInTime'] ?? result['data']?['check_in_time'];
        if (checkInTimeStr != null) {
          checkInTime = DateTime.tryParse(checkInTimeStr);
        }

        debugPrint('✓ Attendance marked on server');
        debugPrint('  Status: $markedStatus');
        debugPrint('  Attendance ID: $attendanceId');
        debugPrint('  Check-in Time: $checkInTime');

      } else if (result['alreadyMarked'] == true) {
        _showWarning('Already Marked', '${student.name} was already marked.');
        return;
      } else {
        debugPrint('✗ Server error: ${result['message']}');
        // Continue to add locally even if server fails
      }
    } catch (e) {
      debugPrint('✗ API Error: $e');
      // Continue to add locally
    }
  }

  // Create updated student with attendance info
  final updatedStudent = student.copyWith(
    isPresent: true,
    isMarkedOnServer: serverSuccess,
    attendanceStatus: markedStatus,
  );

  // Add to scanned list
  scannedStudents.add(updatedStudent);

  // Create local attendance record
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
    scannedBy: _storageService.getUser()?.id,
    scannedByName: _storageService.getUser()?.name ?? 'QR Scanner',
    createdAt: DateTime.now(),
  );

  todayAttendance.add(attendance);

  // Update in all students list
  final index = allStudents.indexWhere((s) => s.id == student.id);
  if (index != -1) {
    allStudents[index] = updatedStudent;
  }

  // Show appropriate success message
  _showAttendanceSuccess(student.name, markedStatus, serverSuccess);
}

// New helper method for showing attendance success
void _showAttendanceSuccess(String studentName, String status, bool synced) {
  String title;
  String message;
  Color bgColor;

  if (status == 'late') {
    title = '⏰ Late';
    message = '$studentName marked as LATE';
    bgColor = Colors.orange;
  } else if (status == 'present') {
    title = '✓ Present';
    message = '$studentName marked present';
    bgColor = Colors.green;
  } else {
    title = '✓ Marked';
    message = '$studentName marked as ${status.toUpperCase()}';
    bgColor = Colors.blue;
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
      status == 'late' ? Icons.access_time : Icons.check_circle,
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
  // CLEAR SCANNED STUDENTS
  // ══════════════════════════════════════════════════════════
  void clearScannedStudents() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Clear all scanned students?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Only clear locally scanned (not server synced)
              final localOnly = scannedStudents
                  .where((s) => !s.isMarkedOnServer)
                  .map((s) => s.id)
                  .toList();

              scannedStudents.removeWhere((s) => localOnly.contains(s.id));
              todayAttendance.removeWhere((a) => localOnly.contains(a.studentId));

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

    if (!isAuthenticated) {
      _showError('Auth Error', 'Please login to save attendance.');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Save Attendance'),
        content: Text('Save ${pendingStudents.length} pending attendance?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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

  Future<void> _syncPendingAttendance(List<StudentModel> pendingStudents) async {
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
          token: _authToken!,
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
        debugPrint('Sync error for ${student.id}: $e');
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _processManualEntry(
              rollController.text,
              rollController,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _processManualEntry(String rollNumber, TextEditingController controller) {
    final roll = rollNumber.trim();
    if (roll.isEmpty) return;

    final student = allStudents.firstWhereOrNull(
      (s) => s.rollNumber?.toLowerCase() == roll.toLowerCase(),
    );

    if (student == null) {
      Get.back();
      _showError('Not Found', 'No student with roll: $roll');
      return;
    }

    final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
    if (alreadyScanned) {
      Get.back();
      _showWarning('Already Marked', '${student.name} is already present.');
      return;
    }

    Get.back();
    markAttendance(student);
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

  void _showSuccess(String studentName, bool synced) {
    Get.snackbar(
      synced ? '✓ Synced' : '✓ Present',
      '$studentName marked present${synced ? ' (saved)' : ' (pending)'}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: synced ? AppTheme.successColor : Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(
        synced ? Icons.cloud_done : Icons.check_circle,
        color: Colors.white,
      ),
    );
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

  int get syncedCount => scannedStudents.where((s) => s.isMarkedOnServer).length;
  int get pendingCount => scannedStudents.where((s) => !s.isMarkedOnServer).length;
}