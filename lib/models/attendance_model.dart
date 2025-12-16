// // lib/models/attendance_model.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'student_model.dart';

// // ══════════════════════════════════════════════════════════
// // ATTENDANCE STATUS ENUM (Matching Mongoose enum)
// // ══════════════════════════════════════════════════════════
// enum AttendanceStatus {
//   present,
//   absent,
//   late,
//   excused,
// }

// extension AttendanceStatusExtension on AttendanceStatus {
//   String get value {
//     switch (this) {
//       case AttendanceStatus.present:
//         return 'present';
//       case AttendanceStatus.absent:
//         return 'absent';
//       case AttendanceStatus.late:
//         return 'late';
//       case AttendanceStatus.excused:
//         return 'excused';
//     }
//   }

//   String get displayName {
//     switch (this) {
//       case AttendanceStatus.present:
//         return 'Present';
//       case AttendanceStatus.absent:
//         return 'Absent';
//       case AttendanceStatus.late:
//         return 'Late';
//       case AttendanceStatus.excused:
//         return 'Excused';
//     }
//   }

//   Color get color {
//     switch (this) {
//       case AttendanceStatus.present:
//         return Colors.green;
//       case AttendanceStatus.absent:
//         return Colors.red;
//       case AttendanceStatus.late:
//         return Colors.orange;
//       case AttendanceStatus.excused:
//         return Colors.blue;
//     }
//   }

//   IconData get icon {
//     switch (this) {
//       case AttendanceStatus.present:
//         return Icons.check_circle;
//       case AttendanceStatus.absent:
//         return Icons.cancel;
//       case AttendanceStatus.late:
//         return Icons.access_time;
//       case AttendanceStatus.excused:
//         return Icons.info;
//     }
//   }

//   static AttendanceStatus fromString(String status) {
//     switch (status.toLowerCase()) {
//       case 'present':
//         return AttendanceStatus.present;
//       case 'absent':
//         return AttendanceStatus.absent;
//       case 'late':
//         return AttendanceStatus.late;
//       case 'excused':
//         return AttendanceStatus.excused;
//       default:
//         return AttendanceStatus.absent;
//     }
//   }
// }

// // ══════════════════════════════════════════════════════════
// // ATTENDANCE MODEL (Matching Mongoose Schema)
// // ══════════════════════════════════════════════════════════
// class AttendanceModel {
//   // ══════════════════════════════════════════════════════════
//   // FIELDS FROM MONGOOSE ATTENDANCE MODEL
//   // ══════════════════════════════════════════════════════════
//   final String id;
//   final String studentId;          // student (ObjectId)
//   final String? classId;           // class_id (ObjectId)
//   final DateTime date;             // date
//   final AttendanceStatus status;   // status
//   final DateTime? checkInTime;     // check_in_time
//   final DateTime? checkOutTime;    // check_out_time
//   final String? scannedBy;         // scanned_by (ObjectId - Teacher/Admin)
//   final DateTime? createdAt;       // createdAt (from timestamps)
//   final DateTime? updatedAt;       // updatedAt (from timestamps)

//   // ══════════════════════════════════════════════════════════
//   // POPULATED FIELDS (When student/scannedBy is populated)
//   // ══════════════════════════════════════════════════════════
//   final StudentModel? student;     // Populated student object
//   final StudentModel? scannedByUser; // Populated scannedBy user object
//   final ClassModel? classInfo;     // Populated class object

//   // ══════════════════════════════════════════════════════════
//   // CONVENIENCE FIELDS (Derived from populated data)
//   // ══════════════════════════════════════════════════════════
//   final String? studentName;
//   final String? studentRollNumber;
//   final String? studentClassName;
//   final String? studentSection;
//   final String? scannedByName;

//   AttendanceModel({
//     required this.id,
//     required this.studentId,
//     this.classId,
//     required this.date,
//     required this.status,
//     this.checkInTime,
//     this.checkOutTime,
//     this.scannedBy,
//     this.createdAt,
//     this.updatedAt,
//     this.student,
//     this.scannedByUser,
//     this.classInfo,
//     this.studentName,
//     this.studentRollNumber,
//     this.studentClassName,
//     this.studentSection,
//     this.scannedByName,
//   });

//   // ══════════════════════════════════════════════════════════
//   // COMPUTED PROPERTIES
//   // ══════════════════════════════════════════════════════════

//   /// Get status string
//   String get statusString => status.value;
//   String get statusDisplay => status.displayName;

//   /// Check if present (includes late)
//   bool get isPresent =>
//       status == AttendanceStatus.present || status == AttendanceStatus.late;

//   /// Check if absent
//   bool get isAbsent => status == AttendanceStatus.absent;

//   /// Get formatted date (DD/MM/YYYY)
//   String get formattedDate {
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   /// Get date string (YYYY-MM-DD)
//   String get dateString {
//     return '${date.year}-'
//         '${date.month.toString().padLeft(2, '0')}-'
//         '${date.day.toString().padLeft(2, '0')}';
//   }

//   /// Get day name
//   String get dayName {
//     const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//     return days[date.weekday - 1];
//   }

//   /// Get short day name
//   String get shortDayName {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[date.weekday - 1];
//   }

//   /// Get formatted check-in time
//   String? get formattedCheckInTime {
//     if (checkInTime == null) return null;
//     return _formatTime(checkInTime!);
//   }

//   /// Get formatted check-out time
//   String? get formattedCheckOutTime {
//     if (checkOutTime == null) return null;
//     return _formatTime(checkOutTime!);
//   }

//   /// Get display name (from populated or direct)
//   String get displayStudentName {
//     return student?.name ?? studentName ?? 'Unknown Student';
//   }

//   /// Get display roll number
//   String get displayRollNumber {
//     return student?.rollNumber ?? studentRollNumber ?? '';
//   }

//   /// Get display class
//   String get displayClass {
//     return classInfo?.name ?? student?.className ?? studentClassName ?? '';
//   }

//   /// Get display section
//   String get displaySection {
//     return classInfo?.section ?? student?.section ?? studentSection ?? '';
//   }

//   /// Get display scanned by name
//   String get displayScannedByName {
//     return scannedByUser?.name ?? scannedByName ?? 'System';
//   }

//   /// Helper to format time
//   static String _formatTime(DateTime time) {
//     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
//     final amPm = time.hour >= 12 ? 'PM' : 'AM';
//     return '${hour.toString().padLeft(2, '0')}:'
//         '${time.minute.toString().padLeft(2, '0')} $amPm';
//   }

//   // ══════════════════════════════════════════════════════════
//   // JSON SERIALIZATION
//   // ══════════════════════════════════════════════════════════

//   /// Factory from JSON (handles both snake_case and camelCase)
//   factory AttendanceModel.fromJson(Map<String, dynamic> json) {
//     // Handle student field (can be ObjectId string or populated object)
//     String studentId;
//     StudentModel? student;
//     String? studentName;
//     String? studentRollNumber;
//     String? studentClassName;
//     String? studentSection;

//     final studentData = json['student'];
//     if (studentData is String) {
//       studentId = studentData;
//     } else if (studentData is Map<String, dynamic>) {
//       studentId = studentData['id']?.toString() ??
//                   studentData['_id']?.toString() ?? '';
//       student = StudentModel.fromJson(studentData);
//       studentName = student.name;
//       studentRollNumber = student.rollNumber;
//       studentClassName = student.className;
//       studentSection = student.section;
//     } else {
//       studentId = json['student_id']?.toString() ??
//                   json['studentId']?.toString() ?? '';
//     }

//     // Handle scanned_by field (can be ObjectId string or populated object)
//     String? scannedBy;
//     StudentModel? scannedByUser;
//     String? scannedByName;

//     final scannedByData = json['scanned_by'] ?? json['scannedBy'];
//     if (scannedByData is String) {
//       scannedBy = scannedByData;
//     } else if (scannedByData is Map<String, dynamic>) {
//       scannedBy = scannedByData['id']?.toString() ??
//                   scannedByData['_id']?.toString();
//       scannedByUser = StudentModel.fromJson(scannedByData);
//       scannedByName = scannedByUser.name;
//     }

//     // Handle class_id field (can be ObjectId string or populated object)
//     String? classId;
//     ClassModel? classInfo;

//     final classData = json['class_id'] ?? json['classId'];
//     if (classData is String) {
//       classId = classData;
//     } else if (classData is Map<String, dynamic>) {
//       classId = classData['id']?.toString() ??
//                 classData['_id']?.toString();
//       classInfo = ClassModel.fromJson(classData);
//     }

//     return AttendanceModel(
//       id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
//       studentId: studentId,
//       classId: classId,
//       date: _parseDate(json['date']),
//       status: AttendanceStatusExtension.fromString(json['status'] ?? 'absent'),
//       checkInTime: _parseDateTime(json['check_in_time'] ?? json['checkInTime']),
//       checkOutTime: _parseDateTime(json['check_out_time'] ?? json['checkOutTime']),
//       scannedBy: scannedBy,
//       createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
//       updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
//       student: student,
//       scannedByUser: scannedByUser,
//       classInfo: classInfo,
//       studentName: studentName ?? json['student_name'] ?? json['studentName'],
//       studentRollNumber: studentRollNumber ??
//                          json['student_roll_number'] ??
//                          json['studentRollNumber'],
//       studentClassName: studentClassName ??
//                         json['student_class'] ??
//                         json['studentClass'],
//       studentSection: studentSection ??
//                       json['student_section'] ??
//                       json['studentSection'],
//       scannedByName: scannedByName ??
//                      json['scanned_by_name'] ??
//                      json['scannedByName'],
//     );
//   }

//   /// Helper to parse date
//   static DateTime _parseDate(dynamic value) {
//     if (value == null) return DateTime.now();
//     if (value is DateTime) return value;
//     if (value is String) {
//       return DateTime.tryParse(value) ?? DateTime.now();
//     }
//     return DateTime.now();
//   }

//   /// Helper to parse DateTime
//   static DateTime? _parseDateTime(dynamic value) {
//     if (value == null) return null;
//     if (value is DateTime) return value;
//     if (value is String) return DateTime.tryParse(value);
//     return null;
//   }

//   /// Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'student': studentId,
//       'class_id': classId,
//       'date': date.toIso8601String(),
//       'status': status.value,
//       'check_in_time': checkInTime?.toIso8601String(),
//       'check_out_time': checkOutTime?.toIso8601String(),
//       'scanned_by': scannedBy,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }

//   /// Convert to JSON for API request (marking attendance)
//   Map<String, dynamic> toMarkingJson() {
//     return {
//       'student_id': studentId,
//       'class_id': classId,
//       'status': status.value,
//     };
//   }

//   /// Convert to JSON string
//   String toJsonString() => jsonEncode(toJson());

//   /// Factory from JSON string
//   factory AttendanceModel.fromJsonString(String jsonString) {
//     return AttendanceModel.fromJson(jsonDecode(jsonString));
//   }

//   /// Copy with method
//   AttendanceModel copyWith({
//     String? id,
//     String? studentId,
//     String? classId,
//     DateTime? date,
//     AttendanceStatus? status,
//     DateTime? checkInTime,
//     DateTime? checkOutTime,
//     String? scannedBy,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     StudentModel? student,
//     StudentModel? scannedByUser,
//     ClassModel? classInfo,
//     String? studentName,
//     String? studentRollNumber,
//     String? studentClassName,
//     String? studentSection,
//     String? scannedByName,
//   }) {
//     return AttendanceModel(
//       id: id ?? this.id,
//       studentId: studentId ?? this.studentId,
//       classId: classId ?? this.classId,
//       date: date ?? this.date,
//       status: status ?? this.status,
//       checkInTime: checkInTime ?? this.checkInTime,
//       checkOutTime: checkOutTime ?? this.checkOutTime,
//       scannedBy: scannedBy ?? this.scannedBy,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       student: student ?? this.student,
//       scannedByUser: scannedByUser ?? this.scannedByUser,
//       classInfo: classInfo ?? this.classInfo,
//       studentName: studentName ?? this.studentName,
//       studentRollNumber: studentRollNumber ?? this.studentRollNumber,
//       studentClassName: studentClassName ?? this.studentClassName,
//       studentSection: studentSection ?? this.studentSection,
//       scannedByName: scannedByName ?? this.scannedByName,
//     );
//   }

//   /// Equality
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is AttendanceModel && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   String toString() {
//     return 'AttendanceModel(id: $id, studentId: $studentId, date: $dateString, status: ${status.displayName})';
//   }

//   /// Create from list
//   static List<AttendanceModel> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => AttendanceModel.fromJson(json)).toList();
//   }

//   /// Convert list to JSON
//   static List<Map<String, dynamic>> toJsonList(List<AttendanceModel> attendances) {
//     return attendances.map((a) => a.toJson()).toList();
//   }
// }

// // ══════════════════════════════════════════════════════════
// // CLASS MODEL (For populated class_id)
// // ══════════════════════════════════════════════════════════
// class ClassModel {
//   final String id;
//   final String name;
//   final String? section;
//   final String? description;
//   final int? capacity;
//   final String? teacherId;
//   final bool isActive;

//   ClassModel({
//     required this.id,
//     required this.name,
//     this.section,
//     this.description,
//     this.capacity,
//     this.teacherId,
//     this.isActive = true,
//   });

//   String get displayName => section != null ? '$name - $section' : name;

//   factory ClassModel.fromJson(Map<String, dynamic> json) {
//     return ClassModel(
//       id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
//       name: json['name'] ?? json['class_name'] ?? '',
//       section: json['section'],
//       description: json['description'],
//       capacity: json['capacity'],
//       teacherId: json['teacher_id']?.toString() ?? json['teacherId']?.toString(),
//       isActive: json['is_active'] ?? json['isActive'] ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'section': section,
//       'description': description,
//       'capacity': capacity,
//       'teacher_id': teacherId,
//       'is_active': isActive,
//     };
//   }
// }

// // ══════════════════════════════════════════════════════════
// // EXTENSIONS FOR LIST OF ATTENDANCE
// // ══════════════════════════════════════════════════════════
// extension AttendanceListExtension on List<AttendanceModel> {
//   /// Filter by status
//   List<AttendanceModel> filterByStatus(AttendanceStatus status) {
//     return where((a) => a.status == status).toList();
//   }

//   /// Filter by date string (YYYY-MM-DD)
//   List<AttendanceModel> filterByDateString(String date) {
//     return where((a) => a.dateString == date).toList();
//   }

//   /// Filter by date
//   List<AttendanceModel> filterByDate(DateTime date) {
//     return where((a) =>
//         a.date.year == date.year &&
//         a.date.month == date.month &&
//         a.date.day == date.day).toList();
//   }

//   /// Filter by date range
//   List<AttendanceModel> filterByDateRange(DateTime start, DateTime end) {
//     return where((a) {
//       return a.date.isAfter(start.subtract(const Duration(days: 1))) &&
//           a.date.isBefore(end.add(const Duration(days: 1)));
//     }).toList();
//   }

//   /// Filter by student
//   List<AttendanceModel> filterByStudent(String studentId) {
//     return where((a) => a.studentId == studentId).toList();
//   }

//   /// Filter by class
//   List<AttendanceModel> filterByClass(String classId) {
//     return where((a) => a.classId == classId).toList();
//   }

//   /// Get present count
//   int get presentCount =>
//       where((a) => a.status == AttendanceStatus.present).length;

//   /// Get absent count
//   int get absentCount =>
//       where((a) => a.status == AttendanceStatus.absent).length;

//   /// Get late count
//   int get lateCount =>
//       where((a) => a.status == AttendanceStatus.late).length;

//   /// Get excused count
//   int get excusedCount =>
//       where((a) => a.status == AttendanceStatus.excused).length;

//   /// Calculate attendance percentage
//   double get attendancePercentage {
//     if (isEmpty) return 0;
//     final present = where((a) =>
//         a.status == AttendanceStatus.present ||
//         a.status == AttendanceStatus.late).length;
//     return (present / length) * 100;
//   }

//   /// Group by date
//   Map<String, List<AttendanceModel>> groupByDate() {
//     final Map<String, List<AttendanceModel>> grouped = {};
//     for (var attendance in this) {
//       final key = attendance.dateString;
//       if (!grouped.containsKey(key)) {
//         grouped[key] = [];
//       }
//       grouped[key]!.add(attendance);
//     }
//     return grouped;
//   }

//   /// Group by student
//   Map<String, List<AttendanceModel>> groupByStudent() {
//     final Map<String, List<AttendanceModel>> grouped = {};
//     for (var attendance in this) {
//       if (!grouped.containsKey(attendance.studentId)) {
//         grouped[attendance.studentId] = [];
//       }
//       grouped[attendance.studentId]!.add(attendance);
//     }
//     return grouped;
//   }

//   /// Sort by date (newest first)
//   List<AttendanceModel> sortByDateDesc() {
//     final sorted = List<AttendanceModel>.from(this);
//     sorted.sort((a, b) => b.date.compareTo(a.date));
//     return sorted;
//   }

//   /// Sort by date (oldest first)
//   List<AttendanceModel> sortByDateAsc() {
//     final sorted = List<AttendanceModel>.from(this);
//     sorted.sort((a, b) => a.date.compareTo(b.date));
//     return sorted;
//   }

//   /// Sort by student name
//   List<AttendanceModel> sortByStudentName() {
//     final sorted = List<AttendanceModel>.from(this);
//     sorted.sort((a, b) => a.displayStudentName.compareTo(b.displayStudentName));
//     return sorted;
//   }

//   /// Get today's attendance
//   List<AttendanceModel> get todayAttendance {
//     final today = DateTime.now();
//     return filterByDate(today);
//   }

//   /// Get this week's attendance
//   List<AttendanceModel> get thisWeekAttendance {
//     final now = DateTime.now();
//     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     final endOfWeek = startOfWeek.add(const Duration(days: 6));
//     return filterByDateRange(startOfWeek, endOfWeek);
//   }

//   /// Get this month's attendance
//   List<AttendanceModel> get thisMonthAttendance {
//     final now = DateTime.now();
//     final startOfMonth = DateTime(now.year, now.month, 1);
//     final endOfMonth = DateTime(now.year, now.month + 1, 0);
//     return filterByDateRange(startOfMonth, endOfMonth);
//   }
// }

// lib/models/attendance_model.dart
// lib/models/attendance_model.dart

// ✅ ADD THIS ENUM
enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

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
    }
  }
}

class AttendanceModel {
  final String id;
  final String studentId;
  final String? classId;
  final DateTime date;
  final AttendanceStatus status; // ✅ CHANGE TO ENUM
  final String? remarks;
  final String? markedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ✅ ADD THESE PROPERTIES
  final String? studentName;
  final String? studentRollNumber;
  final String? studentClassName;
  final String? studentSection;
  final DateTime? checkInTime;
  final String? scannedBy;
  final String? scannedByName;

  AttendanceModel({
    required this.id,
    required this.studentId,
    this.classId,
    required this.date,
    required this.status,
    this.remarks,
    this.markedBy,
    this.createdAt,
    this.updatedAt,
    // ✅ ADD THESE
    this.studentName,
    this.studentRollNumber,
    this.studentClassName,
    this.studentSection,
    this.checkInTime,
    this.scannedBy,
    this.scannedByName,
  });

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLate => status == AttendanceStatus.late;
  bool get isExcused => status == AttendanceStatus.excused;

  String get statusDisplay => status.displayName;

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      classId: json['class_id']?.toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _parseStatus(json['status']?.toString() ?? 'absent'),
      remarks: json['remarks']?.toString(),
      markedBy: json['marked_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      // ✅ ADD THESE
      studentName: json['student_name']?.toString() ?? json['full_name']?.toString(),
      studentRollNumber: json['roll_number']?.toString(),
      studentClassName: json['class_name']?.toString(),
      studentSection: json['section']?.toString(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'].toString())
          : null,
      scannedBy: json['scanned_by']?.toString(),
      scannedByName: json['scanned_by_name']?.toString(),
    );
  }

  // ✅ ADD THIS HELPER
  static AttendanceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      case 'absent':
      default:
        return AttendanceStatus.absent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'date': date.toIso8601String(),
      'status': status.name,
      'remarks': remarks,
      'marked_by': markedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'student_name': studentName,
      'roll_number': studentRollNumber,
      'class_name': studentClassName,
      'section': studentSection,
      'check_in_time': checkInTime?.toIso8601String(),
      'scanned_by': scannedBy,
      'scanned_by_name': scannedByName,
    };
  }

  static List<AttendanceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<AttendanceModel> records) {
    return records.map((r) => r.toJson()).toList();
  }

  @override
  String toString() => 'AttendanceModel(id: $id, date: $date, status: ${status.name})';
}