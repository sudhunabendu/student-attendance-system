// lib/services/student_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/utils/constants.dart';
import '../models/student_model.dart';

class StudentService {
  // ══════════════════════════════════════════════════════════
  // GET ALL STUDENTS
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAllStudents({
    required String token,
    int page = 1,
    int limit = 20,
    String? classId,
    String? section,
    String? search,
    String? status,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (classId != null && classId.isNotEmpty && classId != 'All') {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getStudents)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Get Students Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> studentsList = data['data'] ?? data['students'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Students fetched successfully",
          "students": StudentModel.fromJsonList(studentsList),
          "pagination": data['pagination'] ?? {
            'page': page,
            'limit': limit,
            'total': studentsList.length,
            'totalPages': 1,
          },
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch students",
          "students": <StudentModel>[],
        };
      }
    } catch (e) {
      print("Get Students Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "students": <StudentModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENT BY ID
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getStudentById({
    required String token,
    required String studentId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getStudents}/$studentId',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Get Student By ID Response: $data");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Student fetched successfully",
          "student": StudentModel.fromJson(data['data'] ?? data['student'] ?? data),
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch student",
          "student": null,
        };
      }
    } catch (e) {
      print("Get Student By ID Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "student": null,
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENTS BY CLASS
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getStudentsByClass({
    required String token,
    required String classId,
    String? section,
  }) async {
    try {
      final queryParams = <String, String>{
        'class_id': classId,
      };

      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getStudentsByClass}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Get Students By Class Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> studentsList = data['data'] ?? data['students'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Students fetched successfully",
          "students": StudentModel.fromJsonList(studentsList),
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch students",
          "students": <StudentModel>[],
        };
      }
    } catch (e) {
      print("Get Students By Class Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "students": <StudentModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH STUDENTS
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> searchStudents({
    required String token,
    required String query,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.searchStudents}',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Search Students Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> studentsList = data['data'] ?? data['students'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Search completed",
          "students": StudentModel.fromJsonList(studentsList),
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Search failed",
          "students": <StudentModel>[],
        };
      }
    } catch (e) {
      print("Search Students Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "students": <StudentModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET CLASSES LIST
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getClasses({
    required String token,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getClasses);

      final response = await http.get(
        url,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Get Classes Response: $data");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Classes fetched successfully",
          "classes": data['data'] ?? data['classes'] ?? [],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch classes",
          "classes": [],
        };
      }
    } catch (e) {
      print("Get Classes Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "classes": [],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENT ATTENDANCE HISTORY
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getStudentAttendance({
    required String token,
    required String studentId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getStudentAttendance}/$studentId',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      print("Get Student Attendance Response: $data");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Attendance fetched successfully",
          "attendance": data['data'] ?? data['attendance'] ?? [],
          "stats": data['stats'] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch attendance",
          "attendance": [],
        };
      }
    } catch (e) {
      print("Get Student Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": [],
      };
    }
  }
}