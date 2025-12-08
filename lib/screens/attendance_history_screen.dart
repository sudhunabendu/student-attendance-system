// lib/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_tile.dart';
import '../app/theme/app_theme.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  AttendanceHistoryScreen({Key? key}) : super(key: key);

  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance History'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Present'),
              Tab(text: 'Absent'),
              Tab(text: 'Late'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.attendanceHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _buildAttendanceList('all'),
              _buildAttendanceList('present'),
              _buildAttendanceList('absent'),
              _buildAttendanceList('late'),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceList(String filter) {
    final filteredList = filter == 'all'
        ? controller.attendanceHistory
        : controller.attendanceHistory
            .where((a) => a.status == filter)
            .toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No records found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return AttendanceTile(attendance: filteredList[index]);
      },
    );
  }
}