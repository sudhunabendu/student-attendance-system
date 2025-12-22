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

  String get apiValue {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.excused:
        return 'excused';
    }
  }
}

class AttendanceModel {
  final String id;

  // References
  final String studentId;
  final String? classId;
  final String? scannedBy;        // teacher/admin id

  // Core fields
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  // Optional metadata
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional populated fields (if your API populates them)
  final String? studentName;
  final String? studentRollNumber;
  final String? studentClassName;
  final String? studentSection;

  final String? scannedByName;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.classId,
    this.scannedBy,
    this.checkInTime,
    this.checkOutTime,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.studentName,
    this.studentRollNumber,
    this.studentClassName,
    this.studentSection,
    this.scannedByName,
  });

  // Convenience getters
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

  // ---------- FROM JSON ----------

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // student can be "id" or populated object
    String studentId = '';
    String? studentName;
    String? studentRoll;
    String? studentClassName;
    String? studentSection;

    final studentField = json['student'] ?? json['student_id'];
    if (studentField is String) {
      studentId = studentField;
    } else if (studentField is Map<String, dynamic>) {
      studentId = studentField['_id']?.toString() ?? '';
      studentName = [
        studentField['first_name'],
        studentField['last_name'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(' ');
      studentRoll = studentField['role_number']?.toString() ??
          studentField['roll_number']?.toString();
      // You can extend this if your populated student has class info
    }

    // scanned_by can be id or full object
    String? scannedBy;
    String? scannedByName;
    final scannedByField = json['scanned_by'];
    if (scannedByField is String) {
      scannedBy = scannedByField;
    } else if (scannedByField is Map<String, dynamic>) {
      scannedBy = scannedByField['_id']?.toString();
      scannedByName = [
        scannedByField['first_name'],
        scannedByField['last_name'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(' ');
    }

    return AttendanceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      studentId: studentId,
      classId: json['class_id']?.toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _parseStatus(json['status']?.toString() ?? 'present'),
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'].toString())
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'].toString())
          : null,
      remarks: json['remarks']?.toString(),
      scannedBy: scannedBy,
      scannedByName: scannedByName ?? json['scanned_by_name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
      studentName:
          json['student_name']?.toString() ?? json['full_name']?.toString() ?? studentName,
      studentRollNumber: json['roll_number']?.toString() ?? studentRoll,
      studentClassName: json['class_name']?.toString(),
      studentSection: json['section']?.toString(),
    );
  }

  // ---------- TO JSON ----------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': studentId, // or 'student_id' depending on your API
      'class_id': classId,
      'date': date.toIso8601String(),
      'status': status.apiValue,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'remarks': remarks,
      'scanned_by': scannedBy,
      'scanned_by_name': scannedByName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'student_name': studentName,
      'roll_number': studentRollNumber,
      'class_name': studentClassName,
      'section': studentSection,
    };
  }

  // ---------- LIST HELPERS ----------

  static List<AttendanceModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<AttendanceModel> records) {
    return records.map((r) => r.toJson()).toList();
  }

  // ---------- INTERNAL PARSE ----------

  static AttendanceStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.absent;
    }
  }

  @override
  String toString() =>
      'AttendanceModel(id: $id, studentId: $studentId, date: $date, status: ${status.apiValue})';
}