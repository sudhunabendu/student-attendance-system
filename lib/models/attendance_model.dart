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
  final DateTime? checkOutTime;
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
    this.checkOutTime,
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