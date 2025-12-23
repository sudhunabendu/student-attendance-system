// // lib/models/attendance_response_model.dart

// class AttendanceResponseModel {
//   final String? attendanceId;
//   final String? studentId;
//   final String? studentName;
//   final String? firstName;
//   final String? lastName;
//   final String? rollNumber;
//   final String? email;
//   final String? classId;
//   final String? className;
//   final String status;
//   final DateTime? checkInTime;
//   final DateTime? checkOutTime;
//   final DateTime? date;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   AttendanceResponseModel({
//     this.attendanceId,
//     this.studentId,
//     this.studentName,
//     this.firstName,
//     this.lastName,
//     this.rollNumber,
//     this.email,
//     this.classId,
//     this.className,
//     required this.status,
//     this.checkInTime,
//     this.checkOutTime,
//     this.date,
//     this.createdAt,
//     this.updatedAt,
//   });

//   /// ✅ Fixed factory to handle your actual API response
//   factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
//     // Handle nested student object
//     final student = json['student'];
//     String? firstName;
//     String? lastName;
//     String? studentId;
//     String? rollNumber;
//     String? email;

//     if (student is Map<String, dynamic>) {
//       firstName = student['first_name'] ?? student['firstName'];
//       lastName = student['last_name'] ?? student['lastName'];
//       studentId = student['id']?.toString() ?? student['_id']?.toString();
//       rollNumber = student['role_number']?.toString() ?? 
//                    student['roll_number']?.toString() ?? 
//                    student['rollNumber']?.toString();
//       email = student['email'];
//     } else if (student is String) {
//       // If student is just an ID string
//       studentId = student;
//     }

//     // Handle nested class_id object
//     final classData = json['class_id'] ?? json['classId'];
//     String? classId;
//     String? className;

//     if (classData is Map<String, dynamic>) {
//       classId = classData['id']?.toString() ?? classData['_id']?.toString();
//       className = classData['name'];
//     } else if (classData is String) {
//       classId = classData;
//     }

//     // Build student name
//     String? studentName;
//     if (firstName != null || lastName != null) {
//       studentName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
//     }
//     // Fallback to direct student_name field
//     studentName ??= json['student_name'];

//     return AttendanceResponseModel(
//       attendanceId: json['_id']?.toString() ?? 
//                     json['id']?.toString() ?? 
//                     json['attendance_id']?.toString(),
//       studentId: studentId,
//       studentName: studentName,
//       firstName: firstName,
//       lastName: lastName,
//       rollNumber: rollNumber ?? json['roll_number']?.toString(),
//       email: email,
//       classId: classId,
//       className: className,
//       status: json['status'] ?? 'present',
//       checkInTime: _parseDateTime(json['check_in_time'] ?? json['checkInTime']),
//       checkOutTime: _parseDateTime(json['check_out_time'] ?? json['checkOutTime']),
//       date: _parseDateTime(json['date']),
//       createdAt: _parseDateTime(json['createdAt']),
//       updatedAt: _parseDateTime(json['updatedAt']),
//     );
//   }

//   /// Helper to parse DateTime from various formats
//   static DateTime? _parseDateTime(dynamic value) {
//     if (value == null) return null;
//     if (value is DateTime) return value;
//     if (value is String) return DateTime.tryParse(value);
//     if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
//     return null;
//   }

//   /// Get full name (computed)
//   String get fullName {
//     if (studentName != null && studentName!.isNotEmpty) {
//       return studentName!;
//     }
//     if (firstName != null || lastName != null) {
//       return '${firstName ?? ''} ${lastName ?? ''}'.trim();
//     }
//     return 'Unknown';
//   }

//   /// Get initials for avatar
//   String get initials {
//     if (firstName != null && firstName!.isNotEmpty) {
//       if (lastName != null && lastName!.isNotEmpty) {
//         return '${firstName![0]}${lastName![0]}'.toUpperCase();
//       }
//       return firstName![0].toUpperCase();
//     }
//     if (studentName != null && studentName!.isNotEmpty) {
//       final parts = studentName!.split(' ');
//       if (parts.length >= 2) {
//         return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//       }
//       return studentName![0].toUpperCase();
//     }
//     return 'S';
//   }

//   /// Status checks
//   bool get isPresent => status.toLowerCase() == 'present' || isLate;
//   bool get isLate => status.toLowerCase() == 'late';
//   bool get isAbsent => status.toLowerCase() == 'absent';
//   bool get isExcused => status.toLowerCase() == 'excused';

//   /// Formatted status display
//   String get statusDisplay {
//     switch (status.toLowerCase()) {
//       case 'present':
//         return 'Present ✓';
//       case 'late':
//         return 'Late ⏰';
//       case 'absent':
//         return 'Absent ✗';
//       case 'excused':
//         return 'Excused 📝';
//       default:
//         return status;
//     }
//   }

//   /// Formatted check-in time
//   String get formattedCheckInTime {
//     if (checkInTime == null) return '--:--';
//     final hour = checkInTime!.hour.toString().padLeft(2, '0');
//     final minute = checkInTime!.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   /// Formatted date
//   String get formattedDate {
//     if (date == null) return '';
//     return '${date!.day}/${date!.month}/${date!.year}';
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': attendanceId,
//       'student': {
//         'id': studentId,
//         'first_name': firstName,
//         'last_name': lastName,
//         'role_number': rollNumber,
//         'email': email,
//       },
//       'class_id': {
//         'id': classId,
//         'name': className,
//       },
//       'status': status,
//       'check_in_time': checkInTime?.toIso8601String(),
//       'check_out_time': checkOutTime?.toIso8601String(),
//       'date': date?.toIso8601String(),
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }

//   /// Create from API response wrapper
//   static AttendanceResponseModel? fromApiResponse(Map<String, dynamic> response) {
//     if (response['success'] == true && response['data'] != null) {
//       // return AttendanceResponseModel.fromJson(response);
//       return AttendanceResponseModel.fromJson(response['data']);
//     }
//     return null;
//   }

//   /// Create list from API response
//   static List<AttendanceResponseModel> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => AttendanceResponseModel.fromJson(json)).toList();
//   }

//   @override
//   String toString() {
//     return 'AttendanceResponse(id: $attendanceId, student: $fullName, '
//            'roll: $rollNumber, class: $className, status: $status, '
//            'checkIn: $formattedCheckInTime)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is AttendanceResponseModel && other.attendanceId == attendanceId;
//   }

//   @override
//   int get hashCode => attendanceId.hashCode;
// }

// lib/models/attendance_response_model.dart

class AttendanceResponseModel {
  final String? attendanceId;

  // ---- STUDENT ----
  final String? studentId;
  final String? studentName;
  final String? firstName;
  final String? lastName;
  final String? rollNumber;
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

  AttendanceResponseModel({
    this.attendanceId,
    this.studentId,
    this.studentName,
    this.firstName,
    this.lastName,
    this.rollNumber,
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
  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    // ---------- STUDENT ----------
    final student = json['student'];
    String? firstName;
    String? lastName;
    String? studentId;
    String? rollNumber;
    String? email;

    if (student is Map<String, dynamic>) {
      firstName = student['first_name'] ?? student['firstName'];
      lastName = student['last_name'] ?? student['lastName'];
      studentId = student['id']?.toString() ?? student['_id']?.toString();
      rollNumber = student['role_number']?.toString() ??
          student['roll_number']?.toString() ??
          student['rollNumber']?.toString();
      email = student['email'];
    } else if (student is String) {
      studentId = student;
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
    String? studentName;
    if (firstName != null || lastName != null) {
      studentName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    studentName ??= json['student_name'];

    return AttendanceResponseModel(
      attendanceId: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['attendance_id']?.toString(),
      studentId: studentId,
      studentName: studentName,
      firstName: firstName,
      lastName: lastName,
      rollNumber: rollNumber,
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
  static AttendanceResponseModel? fromApiResponse(
      Map<String, dynamic> response) {
    if (response['success'] == true && response['data'] != null) {
      final model = AttendanceResponseModel.fromJson(response['data']);

      return AttendanceResponseModel(
        attendanceId: model.attendanceId,
        studentId: model.studentId,
        studentName: model.studentName,
        firstName: model.firstName,
        lastName: model.lastName,
        rollNumber: model.rollNumber,
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
    if (studentName != null && studentName!.isNotEmpty) return studentName!;
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
        'student: $fullName, '
        'class: $className, '
        'status: $status, '
        'action: $action)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceResponseModel &&
          other.attendanceId == attendanceId;

  @override
  int get hashCode => attendanceId.hashCode;

  bool get isAbsent => true;
}
