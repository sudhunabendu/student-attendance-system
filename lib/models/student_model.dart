// lib/models/student_model.dart
// import 'dart:convert';

// class StudentModel {
//   final String id;
//   final String name;
//   final String firstName;
//   final String lastName;
//   final String rollNumber;
//   final String registrationNumber;
//   final String className;
//   final String section;
//   final String? profileImage;
//   final String? email;
//   final String? phone;
//   final String? parentName;
//   final String? parentPhone;
//   final String? parentEmail;
//   final String? address;
//   final DateTime? dateOfBirth;
//   final String? gender;
//   final String? bloodGroup;
//   final DateTime? admissionDate;
//   final bool isActive;
//   bool isPresent;
//   bool isLoading;
//   bool isMarkedOnServer;
//   String attendanceStatus;

//   StudentModel({
//     required this.id,
//     required this.name,
//     this.firstName = '',
//     this.lastName = '',
//     required this.rollNumber,
//     this.registrationNumber = '',
//     required this.className,
//     required this.section,
//     this.profileImage,
//     this.email,
//     this.phone,
//     this.parentName,
//     this.parentPhone,
//     this.parentEmail,
//     this.address,
//     this.dateOfBirth,
//     this.gender,
//     this.bloodGroup,
//     this.admissionDate,
//     this.isActive = true,
//     this.isPresent = false,
//     this.isLoading = false,
//     this.isMarkedOnServer = false,
//     this.attendanceStatus = 'absent',
//   });

//   // Get initials for avatar
//   String get initials {
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '${firstName[0]}${lastName[0]}'.toUpperCase();
//     }
//     if (name.isNotEmpty) {
//       final parts = name.split(' ');
//       if (parts.length >= 2) {
//         return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//       }
//       return name[0].toUpperCase();
//     }
//     return 'S';
//   }

//   // Get class with section
//   String get classSection => '$className - $section';

//   // Generate QR Code data for this student
//   String generateQRData() {
//     final qrData = {
//       'id': id,
//       'name': name,
//       'rollNumber': rollNumber,
//       'className': className,
//       'section': section,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     };
//     return jsonEncode(qrData);
//   }

//   // Parse QR Code data (static method)
//   static StudentQRData? parseQRData(String qrString) {
//     try {
//       final data = jsonDecode(qrString);
//       return StudentQRData(
//         id: data['id']?.toString() ?? '',
//         name: data['name']?.toString() ?? '',
//         rollNumber: data['rollNumber']?.toString() ?? '',
//         className: data['className']?.toString() ?? '',
//         section: data['section']?.toString() ?? '',
//         timestamp: data['timestamp'] ?? 0,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // Factory from JSON
//   factory StudentModel.fromJson(Map<String, dynamic> json) {
//     return StudentModel(
//       id: json['id']?.toString() ?? '',
//       name: json['name'] ?? '',
//       firstName: json['firstName'] ?? json['first_name'] ?? '',
//       lastName: json['lastName'] ?? json['last_name'] ?? '',
//       rollNumber: json['rollNumber']?.toString() ?? json['roll_number']?.toString() ?? '',
//       registrationNumber: json['registrationNumber'] ?? json['registration_number'] ?? '',
//       className: json['className'] ?? json['class_name'] ?? json['class'] ?? '',
//       section: json['section'] ?? '',
//       profileImage: json['profileImage'] ?? json['profile_image'],
//       email: json['email'],
//       phone: json['phone'] ?? json['mobile'],
//       parentName: json['parentName'] ?? json['parent_name'],
//       parentPhone: json['parentPhone'] ?? json['parent_phone'],
//       parentEmail: json['parentEmail'] ?? json['parent_email'],
//       address: json['address'],
//       dateOfBirth: json['dateOfBirth'] != null
//           ? DateTime.tryParse(json['dateOfBirth'])
//           : null,
//       gender: json['gender'],
//       bloodGroup: json['bloodGroup'] ?? json['blood_group'],
//       admissionDate: json['admissionDate'] != null
//           ? DateTime.tryParse(json['admissionDate'])
//           : null,
//       isActive: json['isActive'] ?? json['is_active'] ?? true,
//       isPresent: json['isPresent'] ?? json['is_present'] ?? false,
//       attendanceStatus: json['attendanceStatus'] ?? json['attendance_status'] ?? 'absent',
//     );
//   }

//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'firstName': firstName,
//       'lastName': lastName,
//       'rollNumber': rollNumber,
//       'registrationNumber': registrationNumber,
//       'className': className,
//       'section': section,
//       'profileImage': profileImage,
//       'email': email,
//       'phone': phone,
//       'parentName': parentName,
//       'parentPhone': parentPhone,
//       'parentEmail': parentEmail,
//       'address': address,
//       'dateOfBirth': dateOfBirth?.toIso8601String(),
//       'gender': gender,
//       'bloodGroup': bloodGroup,
//       'admissionDate': admissionDate?.toIso8601String(),
//       'isActive': isActive,
//       'isPresent': isPresent,
//       'attendanceStatus': attendanceStatus,
//     };
//   }

//   // Copy with method
//   StudentModel copyWith({
//     String? id,
//     String? name,
//     String? firstName,
//     String? lastName,
//     String? rollNumber,
//     String? registrationNumber,
//     String? className,
//     String? section,
//     String? profileImage,
//     String? email,
//     String? phone,
//     String? parentName,
//     String? parentPhone,
//     String? parentEmail,
//     String? address,
//     DateTime? dateOfBirth,
//     String? gender,
//     String? bloodGroup,
//     DateTime? admissionDate,
//     bool? isActive,
//     bool? isPresent,
//     String? attendanceStatus,
//   }) {
//     return StudentModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       rollNumber: rollNumber ?? this.rollNumber,
//       registrationNumber: registrationNumber ?? this.registrationNumber,
//       className: className ?? this.className,
//       section: section ?? this.section,
//       profileImage: profileImage ?? this.profileImage,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//       parentName: parentName ?? this.parentName,
//       parentPhone: parentPhone ?? this.parentPhone,
//       parentEmail: parentEmail ?? this.parentEmail,
//       address: address ?? this.address,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       gender: gender ?? this.gender,
//       bloodGroup: bloodGroup ?? this.bloodGroup,
//       admissionDate: admissionDate ?? this.admissionDate,
//       isActive: isActive ?? this.isActive,
//       isPresent: isPresent ?? this.isPresent,
//       attendanceStatus: attendanceStatus ?? this.attendanceStatus,
//     );
//   }

//   static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => StudentModel.fromJson(json)).toList();
//   }
// }

// // QR Data Model
// class StudentQRData {
//   final String id;
//   final String name;
//   final String rollNumber;
//   final String className;
//   final String section;
//   final int timestamp;

//   StudentQRData({
//     required this.id,
//     required this.name,
//     required this.rollNumber,
//     required this.className,
//     required this.section,
//     required this.timestamp,
//   });

//   // Check if QR code is valid (within 24 hours)
//   bool get isValid {
//     final now = DateTime.now().millisecondsSinceEpoch;
//     final diff = now - timestamp;
//     return diff < 24 * 60 * 60 * 1000; // 24 hours
//   }
// }

// lib/models/student_model.dart
import 'dart:convert';

/// User status enum matching Mongoose model
enum UserStatus { active, inactive, expired, verified, blocked }

extension UserStatusExtension on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.expired:
        return 'Expired';
      case UserStatus.verified:
        return 'Verified';
      case UserStatus.blocked:
        return 'Blocked';
    }
  }

  static UserStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'expired':
        return UserStatus.expired;
      case 'verified':
        return UserStatus.verified;
      case 'blocked':
        return UserStatus.blocked;
      default:
        return UserStatus.inactive;
    }
  }
}

/// Gender enum matching Mongoose model
enum Gender { male, female, other }

extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.male;
    }
  }
}

class StudentModel {
  // ══════════════════════════════════════════════════════════
  // FIELDS FROM MONGOOSE USER MODEL
  // ══════════════════════════════════════════════════════════
  final String id;
  final String? roleId;
  final Gender gender;
  final String firstName;
  final String lastName;
  final String? rollNumber; // role_number in mongoose (typo in backend?)
  final String? email;
  final String? mobileCode;
  final String? mobileNumber;
  final bool mobileNumberVerified;
  final UserStatus status;
  final bool isOtpNeeded;
  final int? validUpto;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ══════════════════════════════════════════════════════════
  // VIRTUAL/POPULATED FIELDS
  // ══════════════════════════════════════════════════════════
  final UserDetailsModel? userDetails;

  // ══════════════════════════════════════════════════════════
  // CLASS RELATED (From class_id population or separate)
  // ══════════════════════════════════════════════════════════
  final String? classId;
  final String? className;
  final String? section;

  // ══════════════════════════════════════════════════════════
  // LOCAL-ONLY FIELDS (Not from backend)
  // ══════════════════════════════════════════════════════════
  bool isPresent;
  bool isLoading;
  bool isMarkedOnServer;
  String attendanceStatus; // 'present', 'late', 'absent', 'excused'

  StudentModel({
    required this.id,
    this.roleId,
    this.gender = Gender.male,
    this.firstName = '',
    this.lastName = '',
    this.rollNumber,
    this.email,
    this.mobileCode,
    this.mobileNumber,
    this.mobileNumberVerified = false,
    this.status = UserStatus.inactive,
    this.isOtpNeeded = false,
    this.validUpto,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.userDetails,
    this.classId,
    this.className,
    this.section,
    // Local fields
    this.isPresent = false,
    this.isLoading = false,
    this.isMarkedOnServer = false,
    this.attendanceStatus = 'absent',
  });

  // ══════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ══════════════════════════════════════════════════════════

  /// Full name from first and last name
  String get name => '$firstName $lastName'.trim();

  /// Get initials for avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }
    return 'S';
  }

  /// Get class with section
  String get classSection {
    if (className != null && section != null) {
      return '$className - $section';
    }
    return className ?? section ?? '';
  }

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Get profile image from userDetails
  String? get profileImage => userDetails?.profileImage;

  /// Get address from userDetails
  String? get address => userDetails?.address;

  /// Get date of birth from userDetails
  DateTime? get dateOfBirth => userDetails?.dateOfBirth;

  // ══════════════════════════════════════════════════════════
  // QR CODE METHODS
  // ══════════════════════════════════════════════════════════

  /// Generate QR Code data for this student
  String generateQRData() {
    final qrData = {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'className': className,
      'section': section,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  /// Parse QR Code data (static method)
  static StudentQRData? parseQRData(String qrString) {
    try {
      final data = jsonDecode(qrString);
      return StudentQRData(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        rollNumber: data['rollNumber']?.toString() ?? '',
        className: data['className']?.toString() ?? '',
        section: data['section']?.toString() ?? '',
        timestamp: data['timestamp'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // JSON SERIALIZATION
  // ══════════════════════════════════════════════════════════

  /// Factory from JSON (handles both snake_case and camelCase)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? json['roleId']?.toString(),
      gender: GenderExtension.fromString(json['gender'] ?? 'Male'),
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      rollNumber:
          json['role_number']?.toString() ??
          json['roll_number']?.toString() ??
          json['rollNumber']?.toString(),
      email: json['email'],
      mobileCode: json['mobile_code'] ?? json['mobileCode'],
      mobileNumber: json['mobile_number'] ?? json['mobileNumber'],
      mobileNumberVerified:
          json['mobile_number_verified'] ??
          json['mobileNumberVerified'] ??
          false,
      status: UserStatusExtension.fromString(json['status'] ?? 'Inactive'),
      isOtpNeeded: json['is_otp_needed'] ?? json['isOtpNeeded'] ?? false,
      validUpto: json['valid_upto'] ?? json['validUpto'],
      createdBy:
          json['created_by']?.toString() ?? json['createdBy']?.toString(),
      updatedBy:
          json['updated_by']?.toString() ?? json['updatedBy']?.toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      userDetails: json['userDetails'] != null
          ? (json['userDetails'] is List && json['userDetails'].isNotEmpty)
                ? UserDetailsModel.fromJson(json['userDetails'][0])
                : (json['userDetails'] is Map)
                ? UserDetailsModel.fromJson(json['userDetails'])
                : null
          : null,
      classId: json['class_id']?.toString() ?? json['classId']?.toString(),
      className: json['class_name'] ?? json['className'] ?? json['class'],
      section: json['section'],
      // Local fields
      isPresent: json['isPresent'] ?? json['is_present'] ?? false,
      attendanceStatus:
          json['attendanceStatus'] ?? json['attendance_status'] ?? 'absent',
    );
  }

  /// Helper to parse DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'gender': gender.value,
      'first_name': firstName,
      'last_name': lastName,
      'role_number': rollNumber,
      'email': email,
      'mobile_code': mobileCode,
      'mobile_number': mobileNumber,
      'mobile_number_verified': mobileNumberVerified,
      'status': status.value,
      'is_otp_needed': isOtpNeeded,
      'valid_upto': validUpto,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'class_id': classId,
      'class_name': className,
      'section': section,
    };
  }

  /// Copy with method
  StudentModel copyWith({
    String? id,
    String? roleId,
    Gender? gender,
    String? firstName,
    String? lastName,
    String? rollNumber,
    String? email,
    String? mobileCode,
    String? mobileNumber,
    bool? mobileNumberVerified,
    UserStatus? status,
    bool? isOtpNeeded,
    int? validUpto,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserDetailsModel? userDetails,
    String? classId,
    String? className,
    String? section,
    bool? isPresent,
    bool? isLoading,
    bool? isMarkedOnServer,
    String? attendanceStatus,
  }) {
    return StudentModel(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      rollNumber: rollNumber ?? this.rollNumber,
      email: email ?? this.email,
      mobileCode: mobileCode ?? this.mobileCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileNumberVerified: mobileNumberVerified ?? this.mobileNumberVerified,
      status: status ?? this.status,
      isOtpNeeded: isOtpNeeded ?? this.isOtpNeeded,
      validUpto: validUpto ?? this.validUpto,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userDetails: userDetails ?? this.userDetails,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      section: section ?? this.section,
      isPresent: isPresent ?? this.isPresent,
      isLoading: isLoading ?? this.isLoading,
      isMarkedOnServer: isMarkedOnServer ?? this.isMarkedOnServer,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    );
  }

  /// Create from list
  static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StudentModel.fromJson(json)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $name, rollNumber: $rollNumber, status: ${status.value})';
  }
}



// ══════════════════════════════════════════════════════════
// USER DETAILS MODEL (From virtual/populated userDetails)
// ══════════════════════════════════════════════════════════
class UserDetailsModel {
  final String? id;
  final String? userId;
  final String? profileImage;
  final String? address;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final DateTime? admissionDate;
  final String? registrationNumber;

  UserDetailsModel({
    this.id,
    this.userId,
    this.profileImage,
    this.address,
    this.dateOfBirth,
    this.bloodGroup,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.admissionDate,
    this.registrationNumber,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      profileImage: json['profile_image'] ?? json['profileImage'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      bloodGroup: json['blood_group'] ?? json['bloodGroup'],
      parentName: json['parent_name'] ?? json['parentName'],
      parentPhone: json['parent_phone'] ?? json['parentPhone'],
      parentEmail: json['parent_email'] ?? json['parentEmail'],
      admissionDate: json['admission_date'] != null
          ? DateTime.tryParse(json['admission_date'])
          : json['admissionDate'] != null
          ? DateTime.tryParse(json['admissionDate'])
          : null,
      registrationNumber:
          json['registration_number'] ?? json['registrationNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'profile_image': profileImage,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'blood_group': bloodGroup,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'admission_date': admissionDate?.toIso8601String(),
      'registration_number': registrationNumber,
    };
  }
}

// ══════════════════════════════════════════════════════════
// QR DATA MODEL
// ══════════════════════════════════════════════════════════
class StudentQRData {
  final String id;
  final String name;
  final String rollNumber;
  final String className;
  final String section;
  final int timestamp;

  StudentQRData({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.section,
    required this.timestamp,
  });

  /// Check if QR code is valid (within 24 hours)
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;
    return diff < 24 * 60 * 60 * 1000; // 24 hours
  }

  /// Check if QR code is expired
  bool get isExpired => !isValid;

  /// Get remaining validity time
  Duration get remainingValidity {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = (24 * 60 * 60 * 1000) - (now - timestamp);
    return Duration(milliseconds: diff > 0 ? diff : 0);
  }
}
