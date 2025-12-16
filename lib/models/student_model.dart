// // lib/models/student_model.dart
// import 'dart:convert';
// import 'package:flutter/foundation.dart';

// /// User status enum matching Mongoose model
// enum UserStatus { active, inactive, expired, verified, blocked }

// extension UserStatusExtension on UserStatus {
//   String get value {
//     switch (this) {
//       case UserStatus.active:
//         return 'Active';
//       case UserStatus.inactive:
//         return 'Inactive';
//       case UserStatus.expired:
//         return 'Expired';
//       case UserStatus.verified:
//         return 'Verified';
//       case UserStatus.blocked:
//         return 'Blocked';
//     }
//   }

//   static UserStatus fromString(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return UserStatus.active;
//       case 'inactive':
//         return UserStatus.inactive;
//       case 'expired':
//         return UserStatus.expired;
//       case 'verified':
//         return UserStatus.verified;
//       case 'blocked':
//         return UserStatus.blocked;
//       default:
//         return UserStatus.inactive;
//     }
//   }
// }

// /// Gender enum matching Mongoose model
// enum Gender { male, female, other }

// extension GenderExtension on Gender {
//   String get value {
//     switch (this) {
//       case Gender.male:
//         return 'Male';
//       case Gender.female:
//         return 'Female';
//       case Gender.other:
//         return 'Other';
//     }
//   }

//   static Gender fromString(String gender) {
//     switch (gender.toLowerCase()) {
//       case 'male':
//         return Gender.male;
//       case 'female':
//         return Gender.female;
//       case 'other':
//         return Gender.other;
//       default:
//         return Gender.male;
//     }
//   }
// }

// class StudentModel {
//   // ══════════════════════════════════════════════════════════
//   // FIELDS FROM MONGOOSE USER MODEL
//   // ══════════════════════════════════════════════════════════
//   final String id;
//   final String? roleId;
//   final Gender gender;
//   final String firstName;
//   final String lastName;
//   final String? rollNumber; // role_number in mongoose
//   final String? email;
//   final String? mobileCode;
//   final String? mobileNumber;
//   final bool mobileNumberVerified;
//   final UserStatus status;
//   final bool isOtpNeeded;
//   final int? validUpto;
//   final String? createdBy;
//   final String? updatedBy;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   // ══════════════════════════════════════════════════════════
//   // VIRTUAL/POPULATED FIELDS
//   // ══════════════════════════════════════════════════════════
//   final UserDetailsModel? userDetails;

//   // ══════════════════════════════════════════════════════════
//   // CLASS RELATED (From class_id population or separate)
//   // ══════════════════════════════════════════════════════════
//   final String? classId;
//   final String? className;
//   final String? section;

//   // ══════════════════════════════════════════════════════════
//   // LOCAL-ONLY FIELDS (Not from backend)
//   // ══════════════════════════════════════════════════════════
//   bool isPresent;
//   bool isLoading;
//   bool isMarkedOnServer;
//   String attendanceStatus; // 'present', 'late', 'absent', 'excused'

//   StudentModel({
//     required this.id,
//     this.roleId,
//     this.gender = Gender.male,
//     this.firstName = '',
//     this.lastName = '',
//     this.rollNumber,
//     this.email,
//     this.mobileCode,
//     this.mobileNumber,
//     this.mobileNumberVerified = false,
//     this.status = UserStatus.inactive,
//     this.isOtpNeeded = false,
//     this.validUpto,
//     this.createdBy,
//     this.updatedBy,
//     this.createdAt,
//     this.updatedAt,
//     this.userDetails,
//     this.classId,
//     this.className,
//     this.section,
//     // Local fields
//     this.isPresent = false,
//     this.isLoading = false,
//     this.isMarkedOnServer = false,
//     this.attendanceStatus = 'absent',
//   });

//   // ══════════════════════════════════════════════════════════
//   // COMPUTED PROPERTIES
//   // ══════════════════════════════════════════════════════════

//   /// Full name from first and last name
//   String get name => '$firstName $lastName'.trim();

//   /// Get initials for avatar
//   String get initials {
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '${firstName[0]}${lastName[0]}'.toUpperCase();
//     }
//     if (firstName.isNotEmpty) {
//       return firstName[0].toUpperCase();
//     }
//     return 'S';
//   }

//   /// Get class with section
//   String get classSection {
//     if (className != null && section != null) {
//       return '$className - $section';
//     }
//     return className ?? section ?? '';
//   }

//   /// Check if user is active
//   bool get isActive => status == UserStatus.active;

//   /// Get profile image from userDetails
//   String? get profileImage => userDetails?.profileImage;

//   /// Get user_code from userDetails
//   String? get userCode => userDetails?.userCode;

//   /// Get address from userDetails
//   String? get address => userDetails?.address;

//   /// Get date of birth from userDetails
//   DateTime? get dateOfBirth => userDetails?.dateOfBirth;

//   // ══════════════════════════════════════════════════════════
//   // QR CODE METHODS
//   // ══════════════════════════════════════════════════════════

//   /// Generate QR Code data for this student
//   String generateQRData() {
//     final qrData = {
//       'id': id,
//       'name': name,
//       'rollNumber': rollNumber,
//       'userCode': userDetails?.userCode,
//       'className': className,
//       'section': section,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     };
//     return jsonEncode(qrData);
//   }

//   /// Parse QR Code data - supports multiple formats
//   static StudentQRData? parseQRData(String qrString) {
//     if (qrString.trim().isEmpty) {
//       debugPrint('❌ Empty QR code');
//       return null;
//     }

//     final cleanCode = qrString.trim();
//     debugPrint('🔍 Parsing QR: $cleanCode');

//     try {
//       // Try JSON format first
//       if (cleanCode.startsWith('{')) {
//         return _parseJsonQR(cleanCode);
//       }

//       // Try pipe-delimited format: id|rollNumber|name|class|section|timestamp
//       if (cleanCode.contains('|')) {
//         return _parsePipeDelimitedQR(cleanCode);
//       }

//       // Try colon-delimited format: id:rollNumber:timestamp
//       if (cleanCode.contains(':') && !_isMongoObjectId(cleanCode)) {
//         return _parseColonDelimitedQR(cleanCode);
//       }

//       // Simple format - just ID, rollNumber, or userCode
//       return _parseSimpleQR(cleanCode);
//     } catch (e) {
//       debugPrint('❌ QR Parse Error: $e');
//       return null;
//     }
//   }

//   /// Parse JSON format QR
//   static StudentQRData? _parseJsonQR(String qrCode) {
//     try {
//       final data = jsonDecode(qrCode);

//       // Extract ID (try multiple key names)
//       final id = data['id']?.toString() ??
//           data['_id']?.toString() ??
//           data['student_id']?.toString() ??
//           data['studentId']?.toString() ??
//           data['user_id']?.toString() ??
//           data['userId']?.toString();

//       if (id == null || id.isEmpty) {
//         debugPrint('❌ No ID found in JSON QR');
//         return null;
//       }

//       // Parse timestamp
//       int timestamp = 0;
//       if (data['timestamp'] != null) {
//         timestamp = _parseTimestamp(data['timestamp']);
//       } else if (data['generated_at'] != null) {
//         timestamp = _parseTimestamp(data['generated_at']);
//       } else if (data['createdAt'] != null) {
//         timestamp = _parseTimestamp(data['createdAt']);
//       }

//       return StudentQRData(
//         id: id,
//         name: data['name']?.toString() ??
//             '${data['first_name'] ?? data['firstName'] ?? ''} ${data['last_name'] ?? data['lastName'] ?? ''}'
//                 .trim(),
//         rollNumber: data['rollNumber']?.toString() ??
//             data['roll_number']?.toString() ??
//             data['role_number']?.toString() ??
//             '',
//         userCode: data['userCode']?.toString() ??
//             data['user_code']?.toString(),
//         className: data['className']?.toString() ??
//             data['class_name']?.toString() ??
//             data['class']?.toString() ??
//             '',
//         section: data['section']?.toString() ?? '',
//         timestamp: timestamp,
//       );
//     } catch (e) {
//       debugPrint('❌ JSON parse error: $e');
//       return null;
//     }
//   }

//   /// Parse pipe-delimited format: id|rollNumber|name|class|section|timestamp
//   static StudentQRData? _parsePipeDelimitedQR(String qrCode) {
//     try {
//       final parts = qrCode.split('|').map((e) => e.trim()).toList();
//       if (parts.isEmpty || parts[0].isEmpty) return null;

//       int timestamp = 0;
//       // Check if last part is a timestamp
//       if (parts.length > 1) {
//         final lastPart = parts.last;
//         final parsedTs = _parseTimestamp(lastPart);
//         if (parsedTs > 0) {
//           timestamp = parsedTs;
//         }
//       }

//       return StudentQRData(
//         id: parts[0],
//         rollNumber: parts.length > 1 ? parts[1] : '',
//         name: parts.length > 2 ? parts[2] : '',
//         className: parts.length > 3 ? parts[3] : '',
//         section: parts.length > 4 ? parts[4] : '',
//         timestamp: timestamp,
//       );
//     } catch (e) {
//       debugPrint('❌ Pipe parse error: $e');
//       return null;
//     }
//   }

//   /// Parse colon-delimited format: id:rollNumber:timestamp
//   static StudentQRData? _parseColonDelimitedQR(String qrCode) {
//     try {
//       final parts = qrCode.split(':').map((e) => e.trim()).toList();
//       if (parts.isEmpty || parts[0].isEmpty) return null;

//       int timestamp = 0;
//       if (parts.length > 2) {
//         timestamp = _parseTimestamp(parts.last);
//       }

//       return StudentQRData(
//         id: parts[0],
//         rollNumber: parts.length > 1 ? parts[1] : '',
//         name: '',
//         className: '',
//         section: '',
//         timestamp: timestamp,
//       );
//     } catch (e) {
//       debugPrint('❌ Colon parse error: $e');
//       return null;
//     }
//   }

//   /// Parse simple format: just ID, rollNumber, or userCode
//   static StudentQRData? _parseSimpleQR(String qrCode) {
//     if (qrCode.isEmpty) return null;

//     debugPrint('📝 Treating as simple ID/code: $qrCode');

//     return StudentQRData(
//       id: qrCode,
//       rollNumber: qrCode, // Could be rollNumber
//       userCode: qrCode, // Could be userCode
//       name: '',
//       className: '',
//       section: '',
//       timestamp: 0, // No timestamp = always valid
//     );
//   }

//   /// Check if string is a MongoDB ObjectId (24 hex chars)
//   static bool _isMongoObjectId(String value) {
//     if (value.length != 24) return false;
//     return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
//   }

//   /// Parse timestamp from various formats
//   static int _parseTimestamp(dynamic value) {
//     if (value == null) return 0;

//     try {
//       if (value is int) {
//         // Check if seconds or milliseconds
//         if (value > 1000000000000) {
//           return value; // Already milliseconds
//         } else if (value > 1000000000) {
//           return value * 1000; // Convert seconds to milliseconds
//         }
//         return value;
//       }

//       if (value is double) {
//         return value.toInt();
//       }

//       if (value is String) {
//         // Try parsing as int
//         final intVal = int.tryParse(value);
//         if (intVal != null) {
//           return _parseTimestamp(intVal);
//         }

//         // Try parsing as ISO date
//         final dateTime = DateTime.tryParse(value);
//         if (dateTime != null) {
//           return dateTime.millisecondsSinceEpoch;
//         }
//       }
//     } catch (e) {
//       debugPrint('Timestamp parse error: $e');
//     }

//     return 0;
//   }

//   // ══════════════════════════════════════════════════════════
//   // JSON SERIALIZATION
//   // ══════════════════════════════════════════════════════════

//   /// Factory from JSON (handles both snake_case and camelCase)
//   factory StudentModel.fromJson(Map<String, dynamic> json) {
//     return StudentModel(
//       id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
//       roleId: json['role_id']?.toString() ?? json['roleId']?.toString(),
//       gender: GenderExtension.fromString(json['gender'] ?? 'Male'),
//       firstName: json['first_name'] ?? json['firstName'] ?? '',
//       lastName: json['last_name'] ?? json['lastName'] ?? '',
//       rollNumber: json['role_number']?.toString() ??
//           json['roll_number']?.toString() ??
//           json['rollNumber']?.toString(),
//       email: json['email'],
//       mobileCode: json['mobile_code'] ?? json['mobileCode'],
//       mobileNumber: json['mobile_number'] ?? json['mobileNumber'],
//       mobileNumberVerified: json['mobile_number_verified'] ??
//           json['mobileNumberVerified'] ??
//           false,
//       status: UserStatusExtension.fromString(json['status'] ?? 'Inactive'),
//       isOtpNeeded: json['is_otp_needed'] ?? json['isOtpNeeded'] ?? false,
//       validUpto: json['valid_upto'] ?? json['validUpto'],
//       createdBy:
//           json['created_by']?.toString() ?? json['createdBy']?.toString(),
//       updatedBy:
//           json['updated_by']?.toString() ?? json['updatedBy']?.toString(),
//       createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
//       updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
//       userDetails: json['userDetails'] != null
//           ? (json['userDetails'] is List && json['userDetails'].isNotEmpty)
//               ? UserDetailsModel.fromJson(json['userDetails'][0])
//               : (json['userDetails'] is Map)
//                   ? UserDetailsModel.fromJson(json['userDetails'])
//                   : null
//           : null,
//       classId: json['class_id']?.toString() ?? json['classId']?.toString(),
//       className: json['class_name'] ?? json['className'] ?? json['class'],
//       section: json['section'],
//       // Local fields
//       isPresent: json['isPresent'] ?? json['is_present'] ?? false,
//       attendanceStatus:
//           json['attendanceStatus'] ?? json['attendance_status'] ?? 'absent',
//     );
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
//       'role_id': roleId,
//       'gender': gender.value,
//       'first_name': firstName,
//       'last_name': lastName,
//       'role_number': rollNumber,
//       'email': email,
//       'mobile_code': mobileCode,
//       'mobile_number': mobileNumber,
//       'mobile_number_verified': mobileNumberVerified,
//       'status': status.value,
//       'is_otp_needed': isOtpNeeded,
//       'valid_upto': validUpto,
//       'created_by': createdBy,
//       'updated_by': updatedBy,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//       'class_id': classId,
//       'class_name': className,
//       'section': section,
//     };
//   }

//   /// Copy with method
//   StudentModel copyWith({
//     String? id,
//     String? roleId,
//     Gender? gender,
//     String? firstName,
//     String? lastName,
//     String? rollNumber,
//     String? email,
//     String? mobileCode,
//     String? mobileNumber,
//     bool? mobileNumberVerified,
//     UserStatus? status,
//     bool? isOtpNeeded,
//     int? validUpto,
//     String? createdBy,
//     String? updatedBy,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     UserDetailsModel? userDetails,
//     String? classId,
//     String? className,
//     String? section,
//     bool? isPresent,
//     bool? isLoading,
//     bool? isMarkedOnServer,
//     String? attendanceStatus,
//   }) {
//     return StudentModel(
//       id: id ?? this.id,
//       roleId: roleId ?? this.roleId,
//       gender: gender ?? this.gender,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       rollNumber: rollNumber ?? this.rollNumber,
//       email: email ?? this.email,
//       mobileCode: mobileCode ?? this.mobileCode,
//       mobileNumber: mobileNumber ?? this.mobileNumber,
//       mobileNumberVerified: mobileNumberVerified ?? this.mobileNumberVerified,
//       status: status ?? this.status,
//       isOtpNeeded: isOtpNeeded ?? this.isOtpNeeded,
//       validUpto: validUpto ?? this.validUpto,
//       createdBy: createdBy ?? this.createdBy,
//       updatedBy: updatedBy ?? this.updatedBy,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       userDetails: userDetails ?? this.userDetails,
//       classId: classId ?? this.classId,
//       className: className ?? this.className,
//       section: section ?? this.section,
//       isPresent: isPresent ?? this.isPresent,
//       isLoading: isLoading ?? this.isLoading,
//       isMarkedOnServer: isMarkedOnServer ?? this.isMarkedOnServer,
//       attendanceStatus: attendanceStatus ?? this.attendanceStatus,
//     );
//   }

//   /// Create from list
//   static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => StudentModel.fromJson(json)).toList();
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is StudentModel && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   String toString() {
//     return 'StudentModel(id: $id, name: $name, rollNumber: $rollNumber, status: ${status.value})';
//   }
// }

// // ══════════════════════════════════════════════════════════
// // USER DETAILS MODEL (From virtual/populated userDetails)
// // ══════════════════════════════════════════════════════════
// class UserDetailsModel {
//   final String? id;
//   final String? userId;
//   final String? userCode; // user_code from schema
//   final String? profileImage;
//   final String? address;
//   final String? city;
//   final String? postCode;
//   final DateTime? dateOfBirth;
//   final String? bloodGroup;
//   final String? parentName;
//   final String? parentPhone;
//   final String? parentEmail;
//   final DateTime? admissionDate;
//   final String? registrationNumber;
//   final String? classId;
//   final String? personType;
//   final String? accountOrigin;

//   UserDetailsModel({
//     this.id,
//     this.userId,
//     this.userCode,
//     this.profileImage,
//     this.address,
//     this.city,
//     this.postCode,
//     this.dateOfBirth,
//     this.bloodGroup,
//     this.parentName,
//     this.parentPhone,
//     this.parentEmail,
//     this.admissionDate,
//     this.registrationNumber,
//     this.classId,
//     this.personType,
//     this.accountOrigin,
//   });

//   factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
//     return UserDetailsModel(
//       id: json['id']?.toString() ?? json['_id']?.toString(),
//       userId: json['user_id']?.toString() ?? json['userId']?.toString(),
//       userCode: json['user_code'] ?? json['userCode'],
//       profileImage: json['profile_image'] ?? json['profileImage'],
//       address: json['address'],
//       city: json['city'],
//       postCode: json['post_code'] ?? json['postCode'],
//       dateOfBirth: json['birthday'] != null
//           ? DateTime.tryParse(json['birthday'].toString())
//           : json['date_of_birth'] != null
//               ? DateTime.tryParse(json['date_of_birth'].toString())
//               : json['dateOfBirth'] != null
//                   ? DateTime.tryParse(json['dateOfBirth'].toString())
//                   : null,
//       bloodGroup: json['blood_group'] ?? json['bloodGroup'],
//       parentName: json['parent_name'] ?? json['parentName'],
//       parentPhone: json['parent_phone'] ?? json['parentPhone'],
//       parentEmail: json['parent_email'] ?? json['parentEmail'],
//       admissionDate: json['admission_date'] != null
//           ? DateTime.tryParse(json['admission_date'].toString())
//           : json['admissionDate'] != null
//               ? DateTime.tryParse(json['admissionDate'].toString())
//               : null,
//       registrationNumber:
//           json['registration_number'] ?? json['registrationNumber'],
//       classId: json['class_id']?.toString() ?? json['classId']?.toString(),
//       personType: json['person_type'] ?? json['personType'],
//       accountOrigin: json['account_origin'] ?? json['accountOrigin'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'user_code': userCode,
//       'profile_image': profileImage,
//       'address': address,
//       'city': city,
//       'post_code': postCode,
//       'birthday': dateOfBirth?.toIso8601String(),
//       'blood_group': bloodGroup,
//       'parent_name': parentName,
//       'parent_phone': parentPhone,
//       'parent_email': parentEmail,
//       'admission_date': admissionDate?.toIso8601String(),
//       'registration_number': registrationNumber,
//       'class_id': classId,
//       'person_type': personType,
//       'account_origin': accountOrigin,
//     };
//   }

//   @override
//   String toString() {
//     return 'UserDetailsModel(id: $id, userCode: $userCode, classId: $classId)';
//   }
// }

// // ══════════════════════════════════════════════════════════
// // QR DATA MODEL - UPDATED WITH toString() AND BETTER VALIDATION
// // ══════════════════════════════════════════════════════════
// class StudentQRData {
//   final String id;
//   final String name;
//   final String rollNumber;
//   final String? userCode;
//   final String className;
//   final String section;
//   final int timestamp;

//   StudentQRData({
//     required this.id,
//     this.name = '',
//     this.rollNumber = '',
//     this.userCode,
//     this.className = '',
//     this.section = '',
//     this.timestamp = 0,
//   });

//   /// Check if QR code is valid
//   /// - If no timestamp (0), consider always valid
//   /// - If timestamp exists, check if within 24 hours
//   bool get isValid {
//     // No timestamp means no expiration
//     if (timestamp == 0) {
//       return true;
//     }

//     final now = DateTime.now().millisecondsSinceEpoch;
//     final diff = now - timestamp;

//     // Valid if within 24 hours (in milliseconds)
//     return diff < 24 * 60 * 60 * 1000 && diff >= 0;
//   }

//   /// Check if QR code is expired
//   bool get isExpired => !isValid;

//   /// Check if QR has timestamp
//   bool get hasTimestamp => timestamp > 0;

//   /// Get generation time
//   DateTime? get generatedAt {
//     if (timestamp <= 0) return null;
//     return DateTime.fromMillisecondsSinceEpoch(timestamp);
//   }

//   /// Get expiration time
//   DateTime? get expiresAt {
//     if (timestamp <= 0) return null;
//     return DateTime.fromMillisecondsSinceEpoch(
//       timestamp + (24 * 60 * 60 * 1000),
//     );
//   }

//   /// Get remaining validity time
//   Duration get remainingValidity {
//     if (timestamp == 0) {
//       return const Duration(hours: 24); // No expiry
//     }

//     final now = DateTime.now().millisecondsSinceEpoch;
//     final expiryTime = timestamp + (24 * 60 * 60 * 1000);
//     final remaining = expiryTime - now;

//     return Duration(milliseconds: remaining > 0 ? remaining : 0);
//   }

//   /// Get formatted remaining time
//   String get remainingTimeFormatted {
//     if (timestamp == 0) return 'No expiry';

//     final remaining = remainingValidity;
//     if (remaining.inSeconds <= 0) return 'Expired';

//     if (remaining.inHours > 0) {
//       return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
//     }
//     if (remaining.inMinutes > 0) {
//       return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
//     }
//     return '${remaining.inSeconds}s';
//   }

//   /// ✅ IMPORTANT: toString() for proper debugging
//   @override
//   String toString() {
//     return 'StudentQRData('
//         'id: $id, '
//         'name: $name, '
//         'rollNumber: $rollNumber, '
//         'userCode: $userCode, '
//         'className: $className, '
//         'section: $section, '
//         'timestamp: $timestamp, '
//         'generatedAt: $generatedAt, '
//         'isValid: $isValid'
//         ')';
//   }

//   /// Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'rollNumber': rollNumber,
//       'userCode': userCode,
//       'className': className,
//       'section': section,
//       'timestamp': timestamp,
//     };
//   }

//   /// Create from JSON
//   factory StudentQRData.fromJson(Map<String, dynamic> json) {
//     return StudentQRData(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       rollNumber: json['rollNumber']?.toString() ?? '',
//       userCode: json['userCode']?.toString(),
//       className: json['className']?.toString() ?? '',
//       section: json['section']?.toString() ?? '',
//       timestamp: json['timestamp'] ?? 0,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is StudentQRData && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }

// lib/models/student_model.dart

class StudentModel {
  final String id;
  final String roleId;
  final String gender;
  final String firstName;
  final String lastName;
  final String roleNumber;
  final String email;
  final String mobileCode;
  final String mobileNumber;
  final bool mobileNumberVerified;
  final String status;
  final bool isOtpNeeded;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ══════════════════════════════════════════════════════════
  // LOCAL STATE (For UI purposes - not from API)
  // ══════════════════════════════════════════════════════════
  bool isPresent;
  bool isLoading;
  bool isMarkedOnServer;
  bool isSelected;
  String attendanceStatus; // ✅ ADD THIS

  StudentModel({
    required this.id,
    required this.roleId,
    required this.gender,
    required this.firstName,
    required this.lastName,
    required this.roleNumber,
    required this.email,
    required this.mobileCode,
    required this.mobileNumber,
    required this.mobileNumberVerified,
    required this.status,
    required this.isOtpNeeded,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    // Local state defaults
    this.isPresent = false,
    this.isLoading = false,
    this.isMarkedOnServer = false,
    this.isSelected = false,
    this.attendanceStatus = '', // ✅ ADD THIS
  });

  // ══════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ══════════════════════════════════════════════════════════
  
  /// Full name combining first and last name
  String get name => '$firstName $lastName'.trim();
  
  /// Alias for name
  String get fullName => name;
  
  /// Get roll number (alias for roleNumber)
  String get rollNumber => roleNumber;
  
  /// Full mobile number with country code
  String get fullMobileNumber => '$mobileCode$mobileNumber';
  
  /// Get initials for avatar
  String get initials {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  /// Check if student is active
  bool get isActive => status.toLowerCase() == 'active';
  
  /// Check if student is inactive
  bool get isInactive => status.toLowerCase() == 'inactive';
  
  /// Check if student is blocked
  bool get isBlocked => status.toLowerCase() == 'blocked';

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'green';
      case 'inactive':
        return 'orange';
      case 'blocked':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Class name (placeholder - not in current API)
  String? get className => null;
  
  /// Section (placeholder - not in current API)
  String? get section => null;

  // ══════════════════════════════════════════════════════════
  // FROM JSON
  // ══════════════════════════════════════════════════════════
  
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      roleNumber: json['role_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileCode: json['mobile_code']?.toString() ?? '+91',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      mobileNumberVerified: json['mobile_number_verified'] ?? false,
      status: json['status']?.toString() ?? 'Active',
      isOtpNeeded: json['is_otp_needed'] ?? false,
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  // ══════════════════════════════════════════════════════════
  // TO JSON
  // ══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'gender': gender,
      'first_name': firstName,
      'last_name': lastName,
      'role_number': roleNumber,
      'email': email,
      'mobile_code': mobileCode,
      'mobile_number': mobileNumber,
      'mobile_number_verified': mobileNumberVerified,
      'status': status,
      'is_otp_needed': isOtpNeeded,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ══════════════════════════════════════════════════════════
  // FROM JSON LIST
  // ══════════════════════════════════════════════════════════
  
  static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════════════════════
  // COPY WITH
  // ══════════════════════════════════════════════════════════
  
  StudentModel copyWith({
    String? id,
    String? roleId,
    String? gender,
    String? firstName,
    String? lastName,
    String? roleNumber,
    String? email,
    String? mobileCode,
    String? mobileNumber,
    bool? mobileNumberVerified,
    String? status,
    bool? isOtpNeeded,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPresent,
    bool? isLoading,
    bool? isMarkedOnServer,
    bool? isSelected,
    String? attendanceStatus, // ✅ ADD THIS
  }) {
    return StudentModel(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roleNumber: roleNumber ?? this.roleNumber,
      email: email ?? this.email,
      mobileCode: mobileCode ?? this.mobileCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileNumberVerified: mobileNumberVerified ?? this.mobileNumberVerified,
      status: status ?? this.status,
      isOtpNeeded: isOtpNeeded ?? this.isOtpNeeded,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPresent: isPresent ?? this.isPresent,
      isLoading: isLoading ?? this.isLoading,
      isMarkedOnServer: isMarkedOnServer ?? this.isMarkedOnServer,
      isSelected: isSelected ?? this.isSelected,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus, // ✅ ADD THIS

    );
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $fullName, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String get classSection => className ?? section ?? '';

  get profileImage => null;
}