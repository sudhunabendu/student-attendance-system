// lib/models/teacher_model.dart

class TeacherModel {
  final String id;
  final String roleId;
  final String gender;
  final String firstName;
  final String lastName;
  // final String roleNumber;
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
  // ═════════════════════════════════════════════════════════
  bool isPresent;
  bool isLoading;
  bool isMarkedOnServer;
  bool isSelected;
  String attendanceStatus; // ✅ ADD THIS

  TeacherModel({
    required this.id,
    required this.roleId,
    required this.gender,
    required this.firstName,
    required this.lastName,
    // required this.roleNumber,
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
  // String get rollNumber => roleNumber;
  
  /// Full mobile number with country code
  String get fullMobileNumber => '$mobileCode$mobileNumber';
  
  /// Get initials for avatar
  String get initials {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  /// Check if teacher is active
  bool get isActive => status.toLowerCase() == 'active';
  
  /// Check if teacher is inactive
  bool get isInactive => status.toLowerCase() == 'inactive';
  
  /// Check if teacher is blocked
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
  
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      // roleNumber: json['role_number']?.toString() ?? '',
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
      // 'role_number': roleNumber,
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
  
  static List<TeacherModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TeacherModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ══════════════════════════════════════════════════════════
  // COPY WITH
  // ══════════════════════════════════════════════════════════
  
  TeacherModel copyWith({
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
    return TeacherModel(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      // roleNumber: roleNumber ?? this.roleNumber,
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
    return 'TeacherModel(id: $id, name: $fullName, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeacherModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String get classSection => className ?? section ?? '';

  get profileImage => null;
}