// lib/models/user_model.dart
// class UserModel {
//   final String id;
//   final String name;
//   final String email;
//   final String role;
//   final String? profileImage;
//   final String? department;

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     this.profileImage,
//     this.department,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       role: json['role'],
//       profileImage: json['profileImage'],
//       department: json['department'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'role': role,
//       'profileImage': profileImage,
//       'department': department,
//     };
//   }
// }

// // lib/models/student_model.dart
// class StudentModel {
//   final String id;
//   final String name;
//   final String rollNumber;
//   final String className;
//   final String section;
//   final String? profileImage;
//   final String? parentPhone;
//   bool isPresent;

//   StudentModel({
//     required this.id,
//     required this.name,
//     required this.rollNumber,
//     required this.className,
//     required this.section,
//     this.profileImage,
//     this.parentPhone,
//     this.isPresent = false,
//   });

//   factory StudentModel.fromJson(Map<String, dynamic> json) {
//     return StudentModel(
//       id: json['id'],
//       name: json['name'],
//       rollNumber: json['rollNumber'],
//       className: json['className'],
//       section: json['section'],
//       profileImage: json['profileImage'],
//       parentPhone: json['parentPhone'],
//       isPresent: json['isPresent'] ?? false,
//     );
//   }
// }

// // lib/models/attendance_model.dart
// class AttendanceModel {
//   final String id;
//   final String studentId;
//   final String studentName;
//   final String date;
//   final String status; // present, absent, late, excused
//   final String? remarks;
//   final String markedBy;
//   final DateTime markedAt;

//   AttendanceModel({
//     required this.id,
//     required this.studentId,
//     required this.studentName,
//     required this.date,
//     required this.status,
//     this.remarks,
//     required this.markedBy,
//     required this.markedAt,
//   });

//   factory AttendanceModel.fromJson(Map<String, dynamic> json) {
//     return AttendanceModel(
//       id: json['id'],
//       studentId: json['studentId'],
//       studentName: json['studentName'],
//       date: json['date'],
//       status: json['status'],
//       remarks: json['remarks'],
//       markedBy: json['markedBy'],
//       markedAt: DateTime.parse(json['markedAt']),
//     );
//   }
// }

// lib/models/user_model.dart
import 'dart:convert';

class UserModel {
  final String id;
  final String roleId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileCode;
  final String mobileNumber;
  final bool mobileNumberVerified;
  final String gender;
  final String status;
  final bool isOtpNeeded;
  final String? profileImage;
  final String token;
  final String tokenType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileCode,
    required this.mobileNumber,
    required this.mobileNumberVerified,
    required this.gender,
    required this.status,
    required this.isOtpNeeded,
    this.profileImage,
    required this.token,
    required this.tokenType,
    this.createdAt,
    this.updatedAt,
  });

  // Full name getter
  String get name => '$firstName $lastName'.trim();
  
  // Full mobile number
  String get fullMobileNumber => '+$mobileCode $mobileNumber';
  
  // Initials for avatar
  String get initials {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  // Check if profile image exists
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  // Factory from API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested response structure
    final profile = json['profile'] ?? json;
    
    return UserModel(
      id: profile['id']?.toString() ?? '',
      roleId: profile['role_id']?.toString() ?? '',
      firstName: profile['first_name'] ?? '',
      lastName: profile['last_name'] ?? '',
      email: profile['email'] ?? '',
      mobileCode: profile['mobile_code']?.toString() ?? '',
      mobileNumber: profile['mobile_number']?.toString() ?? '',
      mobileNumberVerified: profile['mobile_number_verified'] ?? false,
      gender: profile['gender'] ?? '',
      status: profile['status'] ?? '',
      isOtpNeeded: profile['is_otp_needed'] ?? false,
      profileImage: profile['profile_image'],
      token: profile['token'] ?? '',
      tokenType: profile['token_type'] ?? 'Bearer',
      createdAt: profile['created_at'] != null 
          ? DateTime.tryParse(profile['created_at']) 
          : null,
      updatedAt: profile['updated_at'] != null 
          ? DateTime.tryParse(profile['updated_at']) 
          : null,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile_code': mobileCode,
      'mobile_number': mobileNumber,
      'mobile_number_verified': mobileNumberVerified,
      'gender': gender,
      'status': status,
      'is_otp_needed': isOtpNeeded,
      'profile_image': profileImage,
      'token': token,
      'token_type': tokenType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Factory from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? roleId,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileCode,
    String? mobileNumber,
    bool? mobileNumberVerified,
    String? gender,
    String? status,
    bool? isOtpNeeded,
    String? profileImage,
    String? token,
    String? tokenType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileCode: mobileCode ?? this.mobileCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileNumberVerified: mobileNumberVerified ?? this.mobileNumberVerified,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      isOtpNeeded: isOtpNeeded ?? this.isOtpNeeded,
      profileImage: profileImage ?? this.profileImage,
      token: token ?? this.token,
      tokenType: tokenType ?? this.tokenType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }
}

// Login Response Model
class LoginResponse {
  final int resCode;
  final String response;
  final UserModel? user;
  final String? error;

  LoginResponse({
    required this.resCode,
    required this.response,
    this.user,
    this.error,
  });

  bool get isSuccess => resCode == 200;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    
    if (json['data'] != null && json['data']['nodeLogin'] != null) {
      user = UserModel.fromJson(json['data']['nodeLogin']);
    }
    
    return LoginResponse(
      resCode: json['res_code'] ?? 0,
      response: json['response'] ?? '',
      user: user,
      error: json['error'],
    );
  }

  factory LoginResponse.error(String message) {
    return LoginResponse(
      resCode: 0,
      response: message,
      error: message,
    );
  }
}