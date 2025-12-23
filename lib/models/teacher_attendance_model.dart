enum TeacherAttendanceStatus {
  present,
  absent,
  late,
  excused;

  String get displayName {
    switch (this) {
      case TeacherAttendanceStatus.present:
        return 'Present';
      case TeacherAttendanceStatus.absent:
        return 'Absent';
      case TeacherAttendanceStatus.late:
        return 'Late';
      case TeacherAttendanceStatus.excused:
        return 'Excused';
    }
  }

  String get apiValue {
    switch (this) {
      case TeacherAttendanceStatus.present:
        return 'present';
      case TeacherAttendanceStatus.absent:
        return 'absent';
      case TeacherAttendanceStatus.late:
        return 'late';
      case TeacherAttendanceStatus.excused:
        return 'excused';
    }
  }
}

class TeacherAttendanceModel {
  final String id;

  // References
  final String teacherId;
  // final String? classId;
  final String? scannedBy; // teacher/admin id

  // Core fields
  final DateTime date;
  final TeacherAttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  // Optional metadata
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional populated fields (if your API populates them)
  final String? teacherName;
  // final String? teacherRollNumber;
  // final String? teacherClassName;
  // final String? teacherSection;

  final String? scannedByName;

  TeacherAttendanceModel({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.status,
    // this.classId,
    this.scannedBy,
    this.checkInTime,
    this.checkOutTime,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.teacherName,
    // this.teacherRollNumber,
    // this.teacherClassName,
    // this.teacherSection,
    this.scannedByName,
  });

  // Convenience getters
  bool get isPresent => status == TeacherAttendanceStatus.present;
  bool get isAbsent => status == TeacherAttendanceStatus.absent;
  bool get isLate => status == TeacherAttendanceStatus.late;
  bool get isExcused => status == TeacherAttendanceStatus.excused;

  String get statusDisplay => status.displayName;

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ---------- FROM JSON ----------

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    // teacher can be "id" or populated object
    String teacherId = '';
    String? teacherName;
    // String? teacherRoll;
    // String? teacherClassName;
    // String? teacherSection;

    final teacherField = json['teacher'] ?? json['teacher_id'];
    if (teacherField is String) {
      teacherId = teacherField;
    } else if (teacherField is Map<String, dynamic>) {
      teacherId = teacherField['_id']?.toString() ?? '';
      teacherName = [
        teacherField['first_name'],
        teacherField['last_name'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(' ');
      // teacherRoll =
      //     teacherField['role_number']?.toString() ??
      //     teacherField['roll_number']?.toString();
      // You can extend this if your populated teacher has class info
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

    return TeacherAttendanceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      teacherId: teacherId,
      // classId: json['class_id']?.toString(),
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
      teacherName:
          json['teacher_name']?.toString() ??
          json['full_name']?.toString() ??
          teacherName,
      // teacherRollNumber: json['roll_number']?.toString() ?? teacherRoll,
      // teacherClassName: json['class_name']?.toString(),
      // teacherSection: json['section']?.toString(),
    );
  }

  // ---------- TO JSON ----------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher': teacherId, // or 'teacher_id' depending on your API
      // 'class_id': classId,
      'date': date.toIso8601String(),
      'status': status.apiValue,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'remarks': remarks,
      'scanned_by': scannedBy,
      'scanned_by_name': scannedByName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'teacher_name': teacherName,
      // 'roll_number': teacherRollNumber,
      // 'class_name': teacherClassName,
      // 'section': teacherSection,
    };
  }

  // ---------- LIST HELPERS ----------

  static List<TeacherAttendanceModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => TeacherAttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<TeacherAttendanceModel> records) {
    return records.map((r) => r.toJson()).toList();
  }

  // ---------- INTERNAL PARSE ----------

  static TeacherAttendanceStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'present':
        return TeacherAttendanceStatus.present;
      case 'absent':
        return TeacherAttendanceStatus.absent;
      case 'late':
        return TeacherAttendanceStatus.late;
      case 'excused':
        return TeacherAttendanceStatus.excused;
      default:
        return TeacherAttendanceStatus.absent;
    }
  }

  @override
  String toString() =>
      'AttendanceModel(id: $id, teacherId: $teacherId, date: $date, status: ${status.apiValue})';
}
