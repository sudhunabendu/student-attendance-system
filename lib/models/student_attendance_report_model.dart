// lib/models/student_attendance_report_model.dart
import 'attendance_model.dart';

class StudentAttendanceReportModel {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final String section;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int excusedDays;
  final double attendancePercentage;
  final String period; // e.g., "January 2024", "2024", "Week 1"
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<AttendanceModel> attendanceHistory;

  StudentAttendanceReportModel({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.section,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    this.lateDays = 0,
    this.excusedDays = 0,
    required this.attendancePercentage,
    required this.period,
    this.fromDate,
    this.toDate,
    this.attendanceHistory = const [],
  });

  // Get class with section
  String get classSection => '$className - $section';

  // Get attendance status
  String get attendanceStatus {
    if (attendancePercentage >= 90) return 'Excellent';
    if (attendancePercentage >= 75) return 'Good';
    if (attendancePercentage >= 60) return 'Average';
    return 'Poor';
  }

  // Check if needs attention
  bool get needsAttention => attendancePercentage < 75;

  factory StudentAttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceReportModel(
      studentId: json['studentId'] ?? json['student_id'] ?? '',
      studentName: json['studentName'] ?? json['student_name'] ?? '',
      rollNumber: json['rollNumber'] ?? json['roll_number'] ?? '',
      className: json['className'] ?? json['class_name'] ?? '',
      section: json['section'] ?? '',
      totalDays: json['totalDays'] ?? json['total_days'] ?? 0,
      presentDays: json['presentDays'] ?? json['present_days'] ?? 0,
      absentDays: json['absentDays'] ?? json['absent_days'] ?? 0,
      lateDays: json['lateDays'] ?? json['late_days'] ?? 0,
      excusedDays: json['excusedDays'] ?? json['excused_days'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 
          json['attendance_percentage'] ?? 0).toDouble(),
      period: json['period'] ?? '',
      fromDate: json['fromDate'] != null 
          ? DateTime.parse(json['fromDate']) 
          : null,
      toDate: json['toDate'] != null 
          ? DateTime.parse(json['toDate']) 
          : null,
      attendanceHistory: json['attendanceHistory'] != null
          ? AttendanceModel.fromJsonList(json['attendanceHistory'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'className': className,
      'section': section,
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'excusedDays': excusedDays,
      'attendancePercentage': attendancePercentage,
      'period': period,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'attendanceHistory': AttendanceModel.toJsonList(attendanceHistory),
    };
  }

  // Create from attendance history
  factory StudentAttendanceReportModel.fromHistory({
    required String studentId,
    required String studentName,
    required String rollNumber,
    required String className,
    required String section,
    required String period,
    required List<AttendanceModel> history,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final presentDays = history.where((a) => 
        a.status == AttendanceStatus.present).length;
    final absentDays = history.where((a) => 
        a.status == AttendanceStatus.absent).length;
    final lateDays = history.where((a) => 
        a.status == AttendanceStatus.late).length;
    final excusedDays = history.where((a) => 
        a.status == AttendanceStatus.excused).length;
    
    final totalDays = history.length;
    final percentage = totalDays > 0 
        ? ((presentDays + lateDays) / totalDays * 100) 
        : 0.0;

    return StudentAttendanceReportModel(
      studentId: studentId,
      studentName: studentName,
      rollNumber: rollNumber,
      className: className,
      section: section,
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      excusedDays: excusedDays,
      attendancePercentage: percentage,
      period: period,
      fromDate: fromDate,
      toDate: toDate,
      attendanceHistory: history,
    );
  }

  static List<StudentAttendanceReportModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StudentAttendanceReportModel.fromJson(json)).toList();
  }
}