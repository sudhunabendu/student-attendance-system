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
  String attendanceStatus; // present, absent, late, excused, holiday

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

  // Full name getter
  String get fullName => '$firstName $lastName'.trim().isEmpty ? name : '$firstName $lastName';

  // Age calculation
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Get initials for avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }

  // Get class with section
  String get classSection => '$className - $section';

  // Factory constructor from JSON
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
      profileImage: json['profileImage'] ?? json['profile_image'] ?? json['avatar'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
      parentName: json['parentName'] ?? json['parent_name'] ?? json['guardian_name'],
      parentPhone: json['parentPhone'] ?? json['parent_phone'] ?? json['guardian_phone'],
      parentEmail: json['parentEmail'] ?? json['parent_email'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null || json['date_of_birth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] ?? json['date_of_birth'])
          : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'] ?? json['blood_group'],
      admissionDate: json['admissionDate'] != null || json['admission_date'] != null
          ? DateTime.tryParse(json['admissionDate'] ?? json['admission_date'])
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

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Factory from JSON string
  factory StudentModel.fromJsonString(String jsonString) {
    return StudentModel.fromJson(jsonDecode(jsonString));
  }

  // Copy with method for immutability
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

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // toString for debugging
  @override
  String toString() {
    return 'StudentModel(id: $id, name: $name, rollNumber: $rollNumber, class: $classSection)';
  }

  // Create empty student
  factory StudentModel.empty() {
    return StudentModel(
      id: '',
      name: '',
      rollNumber: '',
      className: '',
      section: '',
    );
  }

  // Create from list of JSON
  static List<StudentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StudentModel.fromJson(json)).toList();
  }

  // Convert list to JSON
  static List<Map<String, dynamic>> toJsonList(List<StudentModel> students) {
    return students.map((student) => student.toJson()).toList();
  }
}

// Extension for List of Students
extension StudentListExtension on List<StudentModel> {
  // Filter by class
  List<StudentModel> filterByClass(String className) {
    if (className == 'All') return this;
    return where((student) => student.className == className).toList();
  }

  // Filter by section
  List<StudentModel> filterBySection(String section) {
    if (section == 'All') return this;
    return where((student) => student.section == section).toList();
  }

  // Filter by search query
  List<StudentModel> search(String query) {
    if (query.isEmpty) return this;
    final lowerQuery = query.toLowerCase();
    return where((student) =>
        student.name.toLowerCase().contains(lowerQuery) ||
        student.rollNumber.toLowerCase().contains(lowerQuery) ||
        student.registrationNumber.toLowerCase().contains(lowerQuery)).toList();
  }

  // Get present students
  List<StudentModel> get presentStudents =>
      where((student) => student.isPresent).toList();

  // Get absent students
  List<StudentModel> get absentStudents =>
      where((student) => !student.isPresent).toList();

  // Get attendance count
  int get presentCount => where((student) => student.isPresent).length;
  int get absentCount => where((student) => !student.isPresent).length;

  // Sort by roll number
  List<StudentModel> sortByRollNumber() {
    final sorted = List<StudentModel>.from(this);
    sorted.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    return sorted;
  }

  // Sort by name
  List<StudentModel> sortByName() {
    final sorted = List<StudentModel>.from(this);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }
}