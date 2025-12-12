// lib/widgets/attendance_tile.dart
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../app/theme/app_theme.dart';

class AttendanceTile extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceTile({
    Key? key,
    required this.attendance,
  }) : super(key: key);

  Color _getStatusColor() {
    // ✅ FIXED: Using enum instead of string comparison
    switch (attendance.status) {
      case AttendanceStatus.present:
        return AppTheme.successColor;
      case AttendanceStatus.absent:
        return AppTheme.errorColor;
      case AttendanceStatus.late:
        return AppTheme.warningColor;
      case AttendanceStatus.excused:
        return Colors.blue;
      // case AttendanceStatus.holiday:
        // return Colors.purple;
      // case AttendanceStatus.halfDay:
        // return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    // ✅ FIXED: Using enum instead of string comparison
    switch (attendance.status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.info;
      // case AttendanceStatus.holiday:
      //   return Icons.celebration;
      // case AttendanceStatus.halfDay:
      //   return Icons.timelapse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          "${attendance.studentName}",
          // attendance.studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Date: ${attendance.formattedDate}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            attendance.statusDisplay.toUpperCase(), // ✅ Using statusDisplay getter
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}