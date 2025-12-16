// lib/models/daily_attendance_model.dart
import 'attendance_model.dart';

class DailyAttendanceModel {
  final String date;
  final String className;
  final String section;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double attendancePercentage;
  final String markedBy;
  final DateTime? markedAt;
  final bool isComplete;
  final List<AttendanceModel> attendanceRecords;

  DailyAttendanceModel({
    required this.date,
    required this.className,
    required this.section,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    this.lateCount = 0,
    this.excusedCount = 0,
    required this.attendancePercentage,
    required this.markedBy,
    this.markedAt,
    this.isComplete = false,
    this.attendanceRecords = const [],
  });

  // Get formatted date
  String get formattedDate {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return date;
  }

  // Get class with section
  String get classSection => '$className - $section';

  // Check if all students are marked
  bool get isFullyMarked => 
      (presentCount + absentCount + lateCount + excusedCount) >= totalStudents;

  factory DailyAttendanceModel.fromJson(Map<String, dynamic> json) {
    final records = json['attendanceRecords'] != null
        ? AttendanceModel.fromJsonList(json['attendanceRecords'])
        : <AttendanceModel>[];
        
    return DailyAttendanceModel(
      date: json['date'] ?? '',
      className: json['className'] ?? json['class_name'] ?? '',
      section: json['section'] ?? '',
      totalStudents: json['totalStudents'] ?? json['total_students'] ?? 0,
      presentCount: json['presentCount'] ?? json['present_count'] ?? 0,
      absentCount: json['absentCount'] ?? json['absent_count'] ?? 0,
      lateCount: json['lateCount'] ?? json['late_count'] ?? 0,
      excusedCount: json['excusedCount'] ?? json['excused_count'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 
          json['attendance_percentage'] ?? 0).toDouble(),
      markedBy: json['markedBy'] ?? json['marked_by'] ?? '',
      markedAt: json['markedAt'] != null 
          ? DateTime.parse(json['markedAt'])
          : json['marked_at'] != null
              ? DateTime.parse(json['marked_at'])
              : null,
      isComplete: json['isComplete'] ?? json['is_complete'] ?? false,
      attendanceRecords: records,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'className': className,
      'section': section,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'lateCount': lateCount,
      'excusedCount': excusedCount,
      'attendancePercentage': attendancePercentage,
      'markedBy': markedBy,
      'markedAt': markedAt?.toIso8601String(),
      'isComplete': isComplete,
      'attendanceRecords': AttendanceModel.toJsonList(attendanceRecords),
    };
  }

  // Calculate from attendance records
  // factory DailyAttendanceModel.fromRecords({
  //   required String date,
  //   required String className,
  //   required String section,
  //   required List<AttendanceModel> records,
  //   required String markedBy,
  // }) {
  //   final presentCount = records.where((r) => 
  //       r.status == AttendanceStatus.present).length;
  //   final absentCount = records.where((r) => 
  //       r.status == AttendanceStatus.absent).length;
  //   final lateCount = records.where((r) => 
  //       r.status == AttendanceStatus.late).length;
  //   final excusedCount = records.where((r) => 
  //       r.status == AttendanceStatus.excused).length;
    
  //   final total = records.length;
  //   final percentage = total > 0 
  //       ? ((presentCount + lateCount) / total * 100) 
  //       : 0.0;

  //   return DailyAttendanceModel(
  //     date: date,
  //     className: className,
  //     section: section,
  //     totalStudents: total,
  //     presentCount: presentCount,
  //     absentCount: absentCount,
  //     lateCount: lateCount,
  //     excusedCount: excusedCount,
  //     attendancePercentage: percentage,
  //     markedBy: markedBy,
  //     markedAt: DateTime.now(),
  //     isComplete: true,
  //     attendanceRecords: records,
  //   );
  // }

  static List<DailyAttendanceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DailyAttendanceModel.fromJson(json)).toList();
  }
}