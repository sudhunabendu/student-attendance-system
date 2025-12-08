// lib/models/attendance_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';

// Enum for attendance status
enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
  holiday,
  halfDay,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.excused:
        return 'excused';
      case AttendanceStatus.holiday:
        return 'holiday';
      case AttendanceStatus.halfDay:
        return 'half_day';
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.halfDay:
        return 'Half Day';
    }
  }

  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      case 'holiday':
        return AttendanceStatus.holiday;
      case 'half_day':
      case 'halfday':
        return AttendanceStatus.halfDay;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentRollNumber;
  final String? studentClass;
  final String? studentSection;
  final String date; // Format: YYYY-MM-DD
  final AttendanceStatus status;
  final String? remarks;
  final String? reason;
  final String markedBy;
  final String? markedByName;
  final DateTime markedAt;
  final DateTime? updatedAt;
  final String? updatedBy;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  final bool isLateEntry;
  final bool isEarlyExit;
  final String? parentNotified;
  final String? notificationSentAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentRollNumber,
    this.studentClass,
    this.studentSection,
    required this.date,
    required this.status,
    this.remarks,
    this.reason,
    required this.markedBy,
    this.markedByName,
    required this.markedAt,
    this.updatedAt,
    this.updatedBy,
    this.checkInTime,
    this.checkOutTime,
    this.isLateEntry = false,
    this.isEarlyExit = false,
    this.parentNotified,
    this.notificationSentAt,
  });

  // Get status string
  String get statusString => status.value;
  String get statusDisplay => status.displayName;

  // Check if present (includes late)
  bool get isPresent =>
      status == AttendanceStatus.present ||
      status == AttendanceStatus.late ||
      status == AttendanceStatus.halfDay;

  // Check if absent
  bool get isAbsent => status == AttendanceStatus.absent;

  // Get formatted date
  String get formattedDate {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return date;
  }

  // Get DateTime from date string
  DateTime get dateTime => DateTime.parse(date);

  // Get day name
  String get dayName {
    final dt = DateTime.parse(date);
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dt.weekday - 1];
  }

  // Get short day name
  String get shortDayName {
    final dt = DateTime.parse(date);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }

  // Factory from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? json['student_id']?.toString() ?? '',
      studentName: json['studentName'] ?? json['student_name'] ?? '',
      studentRollNumber: json['studentRollNumber'] ?? json['student_roll_number'],
      studentClass: json['studentClass'] ?? json['student_class'],
      studentSection: json['studentSection'] ?? json['student_section'],
      date: json['date'] ?? '',
      status: AttendanceStatusExtension.fromString(
          json['status'] ?? json['attendance_status'] ?? 'absent'),
      remarks: json['remarks'],
      reason: json['reason'],
      markedBy: json['markedBy']?.toString() ?? json['marked_by']?.toString() ?? '',
      markedByName: json['markedByName'] ?? json['marked_by_name'],
      markedAt: json['markedAt'] != null
          ? DateTime.parse(json['markedAt'])
          : json['marked_at'] != null
              ? DateTime.parse(json['marked_at'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      updatedBy: json['updatedBy'] ?? json['updated_by'],
      checkInTime: _parseTimeOfDay(json['checkInTime'] ?? json['check_in_time']),
      checkOutTime: _parseTimeOfDay(json['checkOutTime'] ?? json['check_out_time']),
      isLateEntry: json['isLateEntry'] ?? json['is_late_entry'] ?? false,
      isEarlyExit: json['isEarlyExit'] ?? json['is_early_exit'] ?? false,
      parentNotified: json['parentNotified'] ?? json['parent_notified'],
      notificationSentAt: json['notificationSentAt'] ?? json['notification_sent_at'],
    );
  }

  // Helper to parse TimeOfDay
  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  // Helper to format TimeOfDay
  static String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentRollNumber': studentRollNumber,
      'studentClass': studentClass,
      'studentSection': studentSection,
      'date': date,
      'status': status.value,
      'remarks': remarks,
      'reason': reason,
      'markedBy': markedBy,
      'markedByName': markedByName,
      'markedAt': markedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'checkInTime': _formatTimeOfDay(checkInTime),
      'checkOutTime': _formatTimeOfDay(checkOutTime),
      'isLateEntry': isLateEntry,
      'isEarlyExit': isEarlyExit,
      'parentNotified': parentNotified,
      'notificationSentAt': notificationSentAt,
    };
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Factory from JSON string
  factory AttendanceModel.fromJsonString(String jsonString) {
    return AttendanceModel.fromJson(jsonDecode(jsonString));
  }

  // Copy with method
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentRollNumber,
    String? studentClass,
    String? studentSection,
    String? date,
    AttendanceStatus? status,
    String? remarks,
    String? reason,
    String? markedBy,
    String? markedByName,
    DateTime? markedAt,
    DateTime? updatedAt,
    String? updatedBy,
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    bool? isLateEntry,
    bool? isEarlyExit,
    String? parentNotified,
    String? notificationSentAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentClass: studentClass ?? this.studentClass,
      studentSection: studentSection ?? this.studentSection,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      reason: reason ?? this.reason,
      markedBy: markedBy ?? this.markedBy,
      markedByName: markedByName ?? this.markedByName,
      markedAt: markedAt ?? this.markedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isLateEntry: isLateEntry ?? this.isLateEntry,
      isEarlyExit: isEarlyExit ?? this.isEarlyExit,
      parentNotified: parentNotified ?? this.parentNotified,
      notificationSentAt: notificationSentAt ?? this.notificationSentAt,
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AttendanceModel(id: $id, studentName: $studentName, date: $date, status: ${status.displayName})';
  }

  // Create from list
  static List<AttendanceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AttendanceModel.fromJson(json)).toList();
  }

  // Convert list to JSON
  static List<Map<String, dynamic>> toJsonList(List<AttendanceModel> attendances) {
    return attendances.map((a) => a.toJson()).toList();
  }
}

// TimeOfDay extension for comparison
extension TimeOfDayExtension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String format12Hour() {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }
}

// Extension for List of Attendance
extension AttendanceListExtension on List<AttendanceModel> {
  // Filter by status
  List<AttendanceModel> filterByStatus(AttendanceStatus status) {
    return where((a) => a.status == status).toList();
  }

  // Filter by date
  List<AttendanceModel> filterByDate(String date) {
    return where((a) => a.date == date).toList();
  }

  // Filter by date range
  List<AttendanceModel> filterByDateRange(DateTime start, DateTime end) {
    return where((a) {
      final date = DateTime.parse(a.date);
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Filter by student
  List<AttendanceModel> filterByStudent(String studentId) {
    return where((a) => a.studentId == studentId).toList();
  }

  // Filter by class
  List<AttendanceModel> filterByClass(String className) {
    return where((a) => a.studentClass == className).toList();
  }

  // Get present count
  int get presentCount =>
      where((a) => a.status == AttendanceStatus.present).length;

  // Get absent count
  int get absentCount =>
      where((a) => a.status == AttendanceStatus.absent).length;

  // Get late count
  int get lateCount => where((a) => a.status == AttendanceStatus.late).length;

  // Calculate attendance percentage
  double get attendancePercentage {
    if (isEmpty) return 0;
    final present = where((a) =>
        a.status == AttendanceStatus.present ||
        a.status == AttendanceStatus.late).length;
    return (present / length) * 100;
  }

  // Group by date
  Map<String, List<AttendanceModel>> groupByDate() {
    final Map<String, List<AttendanceModel>> grouped = {};
    for (var attendance in this) {
      if (!grouped.containsKey(attendance.date)) {
        grouped[attendance.date] = [];
      }
      grouped[attendance.date]!.add(attendance);
    }
    return grouped;
  }

  // Group by student
  Map<String, List<AttendanceModel>> groupByStudent() {
    final Map<String, List<AttendanceModel>> grouped = {};
    for (var attendance in this) {
      if (!grouped.containsKey(attendance.studentId)) {
        grouped[attendance.studentId] = [];
      }
      grouped[attendance.studentId]!.add(attendance);
    }
    return grouped;
  }

  // Sort by date (newest first)
  List<AttendanceModel> sortByDateDesc() {
    final sorted = List<AttendanceModel>.from(this);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // Sort by date (oldest first)
  List<AttendanceModel> sortByDateAsc() {
    final sorted = List<AttendanceModel>.from(this);
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  // Sort by student name
  List<AttendanceModel> sortByStudentName() {
    final sorted = List<AttendanceModel>.from(this);
    sorted.sort((a, b) => a.studentName.compareTo(b.studentName));
    return sorted;
  }
}