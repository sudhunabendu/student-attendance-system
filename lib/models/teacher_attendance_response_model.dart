// lib/models/teacher_attendance_response_model.dart

class TeacherAttendanceResponseModel {
  final String? attendanceId;

  // ---- TEACHER ----
  final String? teacherId;
  final String? teacherName;
  final String? firstName;
  final String? lastName;
  // final String? rollNumber;
  final String? email;

  // ---- CLASS ----
  final String? classId;
  final String? className;

  // ---- ATTENDANCE ----
  final String status;
  final String? action; // ✅ ADDED (check_in / check_out)
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeacherAttendanceResponseModel({
    this.attendanceId,
    this.teacherId,
    this.teacherName,
    this.firstName,
    this.lastName,
    // this.rollNumber,
    this.email,
    this.classId,
    this.className,
    this.action, // ✅
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ Handles ONLY `data` object
  factory TeacherAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    // ---------- TEACHER ----------
    final teacher = json['teacher'];
    String? firstName;
    String? lastName;
    String? teacherId;
    // String? rollNumber;
    String? email;

    if (teacher is Map<String, dynamic>) {
      firstName = teacher['first_name'] ?? teacher['firstName'];
      lastName = teacher['last_name'] ?? teacher['lastName'];
      teacherId = teacher['id']?.toString() ?? teacher['_id']?.toString();
      // rollNumber = teacher['role_number']?.toString() ??
          teacher['roll_number']?.toString() ??
          teacher['rollNumber']?.toString();
      email = teacher['email'];
    } else if (teacher is String) {
      teacherId = teacher;
    }

    // ---------- CLASS ----------
    final classData = json['class_id'] ?? json['classId'];
    String? classId;
    String? className;

    if (classData is Map<String, dynamic>) {
      classId = classData['id']?.toString() ?? classData['_id']?.toString();
      className = classData['name'];
    } else if (classData is String) {
      classId = classData;
    }

    // ---------- NAME ----------
    String? teacherName;
    if (firstName != null || lastName != null) {
      teacherName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    teacherName ??= json['teacher_name'];

    return TeacherAttendanceResponseModel(
      attendanceId: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['attendance_id']?.toString(),
      teacherId: teacherId,
      teacherName: teacherName,
      firstName: firstName,
      lastName: lastName,
      // rollNumber: rollNumber,
      email: email,
      classId: classId,
      className: className,
      status: json['status'] ?? 'present',
      checkInTime: _parseDateTime(json['check_in_time']),
      checkOutTime: _parseDateTime(json['check_out_time']),
      date: _parseDateTime(json['date']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// ✅ Parse API wrapper (success, action, message, data)
  static TeacherAttendanceResponseModel? fromApiResponse(
      Map<String, dynamic> response) {
    if (response['success'] == true && response['data'] != null) {
      final model = TeacherAttendanceResponseModel.fromJson(response['data']);

      return TeacherAttendanceResponseModel(
        attendanceId: model.attendanceId,
        teacherId: model.teacherId,
        teacherName: model.teacherName,
        firstName: model.firstName,
        lastName: model.lastName,
        // rollNumber: model.rollNumber,
        email: model.email,
        classId: model.classId,
        className: model.className,
        status: model.status,
        checkInTime: model.checkInTime,
        checkOutTime: model.checkOutTime,
        date: model.date,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,

        // ✅ ACTION FROM TOP LEVEL
        action: response['action'],
      );
    }
    return null;
  }

  /// ---------- HELPERS ----------
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  String get fullName {
    if (teacherName != null && teacherName!.isNotEmpty) return teacherName!;
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return 'Unknown';
  }

  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      final l = (lastName != null && lastName!.isNotEmpty)
          ? lastName![0]
          : '';
      return '${firstName![0]}$l'.toUpperCase();
    }
    return 'S';
  }

  /// ---------- STATUS ----------
  bool get isCheckIn => action == 'check_in';
  bool get isCheckOut => action == 'check_out';

  bool get isLate => status.toLowerCase() == 'late';
  bool get isPresent => status.toLowerCase() == 'present' || isLate;

  String get formattedCheckInTime {
    if (checkInTime == null) return '--:--';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:'
        '${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    if (date == null) return '';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  @override
  String toString() {
    return 'AttendanceResponse('
        'id: $attendanceId, '
        'teacher: $fullName, '
        'class: $className, '
        'status: $status, '
        'action: $action)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAttendanceResponseModel &&
          other.attendanceId == attendanceId;

  @override
  int get hashCode => attendanceId.hashCode;

  bool get isAbsent => true;
}
