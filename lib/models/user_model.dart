// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? department;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profileImage: json['profileImage'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'department': department,
    };
  }
}

// lib/models/student_model.dart
class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  final String className;
  final String section;
  final String? profileImage;
  final String? parentPhone;
  bool isPresent;

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.section,
    this.profileImage,
    this.parentPhone,
    this.isPresent = false,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      rollNumber: json['rollNumber'],
      className: json['className'],
      section: json['section'],
      profileImage: json['profileImage'],
      parentPhone: json['parentPhone'],
      isPresent: json['isPresent'] ?? false,
    );
  }
}

// lib/models/attendance_model.dart
class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String date;
  final String status; // present, absent, late, excused
  final String? remarks;
  final String markedBy;
  final DateTime markedAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    required this.markedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      date: json['date'],
      status: json['status'],
      remarks: json['remarks'],
      markedBy: json['markedBy'],
      markedAt: DateTime.parse(json['markedAt']),
    );
  }
}