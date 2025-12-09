// lib/controllers/qr_scanner_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../app/theme/app_theme.dart';

class QRScannerController extends GetxController {
  // Scanner state
  final isScanning = true.obs;
  final isFlashOn = false.obs;
  final isFrontCamera = false.obs;
  final isProcessing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // Scanned students
  final scannedStudents = <StudentModel>[].obs;
  final todayAttendance = <AttendanceModel>[].obs;
  
  // Selected date
  final selectedDate = DateTime.now().obs;
  
  // All students (mock data)
  final allStudents = <StudentModel>[].obs;
  
  // Scanner controller
  MobileScannerController? scannerController;
  
  // Last scanned code (to prevent duplicates)
  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
    initScanner();
  }

  @override
  void onClose() {
    scannerController?.dispose();
    super.onClose();
  }

  // Initialize scanner
  void initScanner() {
    try {
      scannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 1000,
      );
      hasError.value = false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize camera: $e';
    }
  }

  // Load mock students
  void loadStudents() {
    allStudents.value = List.generate(
      50,
      (index) => StudentModel(
        id: 'STU${(index + 1).toString().padLeft(3, '0')}',
        name: 'Student ${index + 1}',
        firstName: 'First${index + 1}',
        lastName: 'Last${index + 1}',
        rollNumber: '2024${(index + 1).toString().padLeft(3, '0')}',
        className: ['10th', '11th', '12th'][index % 3],
        section: ['A', 'B', 'C', 'D'][index % 4],
        isPresent: false,
      ),
    );
  }

  // Handle barcode detection
  void onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && !isProcessing.value) {
        processQRCode(barcode.rawValue!);
        break;
      }
    }
  }

  // Handle scanner error
  void onScannerError(MobileScannerException error, StackTrace? stackTrace) {
    hasError.value = true;
    errorMessage.value = 'Camera error: ${error.errorCode.name}';
  }

  // Process scanned QR code
  Future<void> processQRCode(String code) async {
    // Prevent duplicate scans within 2 seconds
    final now = DateTime.now();
    if (lastScannedCode == code && 
        lastScanTime != null && 
        now.difference(lastScanTime!).inSeconds < 2) {
      return;
    }
    
    lastScannedCode = code;
    lastScanTime = now;
    isProcessing.value = true;
    
    try {
      // Parse QR code data
      final qrData = StudentModel.parseQRData(code);
      
      if (qrData == null) {
        _showError('Invalid QR Code', 'This QR code is not valid for attendance.');
        isProcessing.value = false;
        return;
      }
      
      // Find student
      final student = allStudents.firstWhereOrNull(
        (s) => s.id == qrData.id || s.rollNumber == qrData.rollNumber,
      );
      
      if (student == null) {
        _showError('Student Not Found', 'No student found with this QR code.');
        isProcessing.value = false;
        return;
      }
      
      // Check if already scanned today
      final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
      
      if (alreadyScanned) {
        _showWarning('Already Marked', '${student.name} is already marked present today.');
        isProcessing.value = false;
        return;
      }
      
      // Mark attendance
      await markAttendance(student);
      
    } catch (e) {
      _showError('Error', 'Failed to process QR code: $e');
    }
    
    isProcessing.value = false;
  }

  // Mark attendance for student
  Future<void> markAttendance(StudentModel student) async {
    // Vibrate for feedback
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      // Ignore vibration errors
    }
    
    // Update student status
    final updatedStudent = student.copyWith(
      isPresent: true,
      attendanceStatus: 'present',
    );
    
    // Add to scanned list
    scannedStudents.add(updatedStudent);
    
    // Create attendance record
    final attendance = AttendanceModel(
      id: 'ATT${DateTime.now().millisecondsSinceEpoch}',
      studentId: student.id,
      studentName: student.name,
      studentRollNumber: student.rollNumber,
      studentClass: student.className,
      studentSection: student.section,
      date: _formatDate(selectedDate.value),
      status: AttendanceStatus.present,
      markedBy: 'QR_SCANNER',
      markedByName: 'Auto - QR Scan',
      markedAt: DateTime.now(),
      checkInTime: TimeOfDay.now(),
    );
    
    todayAttendance.add(attendance);
    
    // Update in all students list
    final index = allStudents.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      allStudents[index] = updatedStudent;
    }
    
    // Show success message
    _showSuccess(student.name);
  }

  // Toggle flash
  Future<void> toggleFlash() async {
    try {
      await scannerController?.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      _showError('Error', 'Failed to toggle flash');
    }
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    try {
      await scannerController?.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
    } catch (e) {
      _showError('Error', 'Failed to switch camera');
    }
  }

  // Pause/Resume scanning
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

  // Restart scanner
  void restartScanner() {
    scannerController?.dispose();
    initScanner();
    hasError.value = false;
  }

  // Clear today's scanned students
  void clearScannedStudents() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all scanned students?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              scannedStudents.clear();
              todayAttendance.clear();
              
              for (int i = 0; i < allStudents.length; i++) {
                allStudents[i] = allStudents[i].copyWith(
                  isPresent: false,
                  attendanceStatus: 'absent',
                );
              }
              
              Get.back();
              Get.snackbar(
                'Cleared',
                'All scanned students have been cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Save attendance
  Future<void> saveAttendance() async {
    if (scannedStudents.isEmpty) {
      _showError('No Students', 'Please scan at least one student QR code.');
      return;
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('Save Attendance'),
        content: Text('Save attendance for ${scannedStudents.length} students?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              Get.dialog(
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
              
              await Future.delayed(const Duration(seconds: 2));
              
              Get.back();
              
              Get.snackbar(
                'Success',
                'Attendance saved for ${scannedStudents.length} students!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
              
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Manual entry
  void showManualEntry() {
    final TextEditingController rollController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Manual Entry'),
        content: TextField(
          controller: rollController,
          decoration: const InputDecoration(
            labelText: 'Roll Number',
            hintText: 'Enter student roll number',
            prefixIcon: Icon(Icons.numbers),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final rollNumber = rollController.text.trim();
              if (rollNumber.isEmpty) return;
              
              final student = allStudents.firstWhereOrNull(
                (s) => s.rollNumber.toLowerCase() == rollNumber.toLowerCase(),
              );
              
              if (student == null) {
                Get.back();
                _showError('Not Found', 'No student found with roll number: $rollNumber');
                return;
              }
              
              final alreadyScanned = scannedStudents.any((s) => s.id == student.id);
              if (alreadyScanned) {
                Get.back();
                _showWarning('Already Marked', '${student.name} is already marked present.');
                return;
              }
              
              Get.back();
              markAttendance(student);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Remove student from scanned list
  void removeStudent(String studentId) {
    scannedStudents.removeWhere((s) => s.id == studentId);
    todayAttendance.removeWhere((a) => a.studentId == studentId);
    
    final index = allStudents.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      allStudents[index] = allStudents[index].copyWith(
        isPresent: false,
        attendanceStatus: 'absent',
      );
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showSuccess(String studentName) {
    Get.snackbar(
      '✓ Present',
      '$studentName marked present!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String title, String message) {
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

  void _showWarning(String title, String message) {
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

  // Stats
  int get presentCount => scannedStudents.length;
  int get totalStudents => allStudents.length;
  double get attendancePercentage => 
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
}