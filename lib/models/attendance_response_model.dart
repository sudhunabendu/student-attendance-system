// lib/models/attendance_response_model.dart
class AttendanceResponseModel {
  final String? attendanceId;
  final String? classId;
  final String? studentName;
  final String? rollNumber;
  final String status;
  final DateTime? checkInTime;
  final DateTime? date;

  AttendanceResponseModel({
    this.attendanceId,
    this.classId,
    this.studentName,
    this.rollNumber,
    required this.status,
    this.checkInTime,
    this.date,
  });

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceResponseModel(
      attendanceId: json['attendance_id']?.toString(),
      classId: json['class_id']?.toString(),
      studentName: json['student_name'],
      rollNumber: json['roll_number']?.toString(),
      status: json['status'] ?? 'present',
      checkInTime: json['check_in_time'] != null 
          ? DateTime.tryParse(json['check_in_time']) 
          : null,
      date: json['date'] != null 
          ? DateTime.tryParse(json['date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'class_id': classId,
      'student_name': studentName,
      'roll_number': rollNumber,
      'status': status,
      'check_in_time': checkInTime?.toIso8601String(),
      'date': date?.toIso8601String(),
    };
  }

  bool get isPresent => status == 'present' || status == 'late';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'excused':
        return 'Excused';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'AttendanceResponse(id: $attendanceId, student: $studentName, status: $status)';
  }
}