// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_scanner_controller.dart';
import '../app/theme/app_theme.dart';

class QRScannerScreen extends StatelessWidget {
  QRScannerScreen({super.key});

  final QRScannerController controller = Get.put(QRScannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: controller.toggleFlash,
          )),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: controller.toggleCamera,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: controller.showManualEntry,
          ),
        ],
      ),
      body: Obx(() {
        // Show error state
        if (controller.hasError.value) {
          return _buildErrorState();
        }
        
        return Column(
          children: [
            // QR Scanner
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Scanner
                  MobileScanner(
                    controller: controller.scannerController,
                    onDetect: controller.onBarcodeDetected,
                    errorBuilder: (context, error, child) {
                      return _buildCameraError(error);
                    },
                  ),
                  
                  // Overlay
                  _buildScannerOverlay(context),
                  
                  // Processing indicator
                  if (controller.isProcessing.value)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Status badge
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: controller.isScanning.value 
                              ? AppTheme.successColor 
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.isScanning.value 
                                  ? Icons.qr_code_scanner 
                                  : Icons.pause,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isScanning.value ? 'Scanning...' : 'Paused',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Pause button
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.toggleScanning,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            controller.isScanning.value ? Icons.pause : Icons.play_arrow,
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scanned list
            Expanded(
              flex: 2,
              child: _buildScannedPanel(),
            ),
          ],
        );
      }),
      // bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Camera Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.restartScanner,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraError(MobileScannerException error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Camera Error: ${error.errorCode.name}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.restartScanner,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;
    
    return Center(
      child: Container(
        width: scanAreaSize,
        height: scanAreaSize,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildScannedPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Scanned', controller.presentCount.toString(), AppTheme.successColor),
                _buildStat('Total', controller.totalStudents.toString(), Colors.blue),
                _buildStat('Rate', '${controller.attendancePercentage.toStringAsFixed(1)}%', AppTheme.warningColor),
              ],
            )),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  'Scanned (${controller.scannedStudents.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Obx(() => controller.scannedStudents.isNotEmpty
                    ? TextButton.icon(
                        onPressed: controller.clearScannedStudents,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: Obx(() => controller.scannedStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No students scanned', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.scannedStudents.length,
                    itemBuilder: (context, index) {
                      final student = controller.scannedStudents[
                          controller.scannedStudents.length - 1 - index];
                      return _buildStudentTile(student);
                    },
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStudentTile(student) {
    return Dismissible(
      key: Key(student.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.removeStudent(student.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.successColor,
              radius: 18,
              child: Text(
                student.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${student.rollNumber} • ${student.classSection}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: AppTheme.successColor, size: 22),
          ],
        ),
      ),
    );
  }

  // Widget _buildSaveButton() {
  //   return Obx(() => controller.scannedStudents.isNotEmpty
  //       ? Container(
  //           padding: const EdgeInsets.all(16),
  //           color: Colors.white,
  //           child: SafeArea(
  //             child: ElevatedButton.icon(
  //               onPressed: controller.saveAttendance,
  //               icon: const Icon(Icons.save),
  //               label: Text('Save Attendance (${controller.scannedStudents.length})'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppTheme.primaryColor,
  //                 foregroundColor: Colors.white,
  //                 padding: const EdgeInsets.symmetric(vertical: 16),
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //               ),
  //             ),
  //           ),
  //         )
  //       : const SizedBox.shrink());
  // }
}