// lib/models/student_model.dart
import 'dart:convert';

class StudentModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String rollNumber;
  final String registrationNumber;
  final String className;
  final String section;
  final String? profileImage;
  final String? email;
  final String? phone;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final DateTime? admissionDate;
  final bool isActive;
  bool isPresent;
  String attendanceStatus;

  StudentModel({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.rollNumber,
    this.registrationNumber = '',
    required this.className,
    required this.section,
    this.profileImage,
    this.email,
    this.phone,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.admissionDate,
    this.isActive = true,
    this.isPresent = false,
    this.attendanceStatus = 'absent',
  });

  // Get initials for avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return 'S';
  }

  // Get class with section
  String get classSection => '$className - $section';

  // Generate QR Code data for this student
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

  // Parse QR Code data (static method)
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

  // Factory from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      rollNumber: json['rollNumber']?.toString() ?? json['roll_number']?.toString() ?? '',
      registrationNumber: json['registrationNumber'] ?? json['registration_number'] ?? '',
      className: json['className'] ?? json['class_name'] ?? json['class'] ?? '',
      section: json['section'] ?? '',
      profileImage: json['profileImage'] ?? json['profile_image'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
      parentName: json['parentName'] ?? json['parent_name'],
      parentPhone: json['parentPhone'] ?? json['parent_phone'],
      parentEmail: json['parentEmail'] ?? json['parent_email'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'] ?? json['blood_group'],
      admissionDate: json['admissionDate'] != null
          ? DateTime.tryParse(json['admissionDate'])
          : null,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isPresent: json['isPresent'] ?? json['is_present'] ?? false,
      attendanceStatus: json['attendanceStatus'] ?? json['attendance_status'] ?? 'absent',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'rollNumber': rollNumber,
      'registrationNumber': registrationNumber,
      'className': className,
      'section': section,
      'profileImage': profileImage,
      'email': email,
      'phone': phone,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'admissionDate': admissionDate?.toIso8601String(),
      'isActive': isActive,
      'isPresent': isPresent,
      'attendanceStatus': attendanceStatus,
    };
  }

  // Copy with method
  StudentModel copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? rollNumber,
    String? registrationNumber,
    String? className,
    String? section,
    String? profileImage,
    String? email,
    String? phone,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    DateTime? admissionDate,
    bool? isActive,
    bool? isPresent,
    String? attendanceStatus,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      rollNumber: rollNumber ?? this.rollNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      className: className ?? this.className,
      section: section ?? this.section,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      admissionDate: admissionDate ?? this.admissionDate,
      isActive: isActive ?? this.isActive,
      isPresent: isPresent ?? this.isPresent,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    );
  }

  static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StudentModel.fromJson(json)).toList();
  }
}

// QR Data Model
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

  // Check if QR code is valid (within 24 hours)
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;
    return diff < 24 * 60 * 60 * 1000; // 24 hours
  }
}