// lib/services/teacher_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/teacher_model.dart';
import '../app/utils/constants.dart';

class TeacherService {
  // ══════════════════════════════════════════════════════════
  // GET ALL TEACHER (No Auth Required)
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAllteachers({
    int page = 1,
    int limit = 20,
    String? classId,
    String? section,
    String? search,
    String? status,
  }) async {
    try {
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
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getTeachers,
      ).replace(queryParameters: queryParams);

      // print("📡 Calling API: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // print("📥 Response Status: ${response.statusCode}");

      // ✅ Check for HTML response
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        // print("❌ Received HTML instead of JSON!");
        return {
          "success": false,
          "message": "Server returned HTML. Check API URL.",
          "teachers": <TeacherModel>[],
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['res_code'] == 200) {
        final List<dynamic> teacherList = data['data'] ?? [];

        // print("✅ Fetched ${teacherList.length} teachers from API");

        // ✅ Parse teachers with error handling
        List<TeacherModel> teachers = [];
        for (var i = 0; i < teacherList.length; i++) {
          try {
            teachers.add(TeacherModel.fromJson(teacherList[i]));
          } catch (e) {
            // print("❌ Error parsing teacher $i: $e");
          }
        }

        return {
          "success": true,
          "message": data["response"] ?? "Teacher fetched successfully",
          "teachers": teachers,
          "pagination":
              data['pagination'] ??
              {
                'page': page,
                'limit': limit,
                'total': teacherList.length,
                'totalPages': 1,
              },
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch teachers",
          "teachers": <TeacherModel>[],
        };
      }
    } catch (e) {
      print("❌ Get Teacher Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "teachers": <TeacherModel>[],
      };
    }
  }

  // serach teacher  // ══════════════════════════════════════════════════════════
  // SEARCH teacher (No Auth Required)
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> searchTeachers({
    required String token,
    required String query,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.searchTeachers}',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      // print("Search teachers Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> teachersList =
            data['data'] ?? data['teachers'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Search completed",
          "teachers": TeacherModel.fromJsonList(teachersList),
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Search failed",
          "teachers": <TeacherModel>[],
        };
      }
    } catch (e) {
      // print("Search teachers Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "teachers": <TeacherModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET TEACHER BY ID (No Auth Required)
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getTeacherById({
    required String teacherId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getTeachers}/$teacherId',
      );

      // print("📤 Fetching teacher: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      // print("📥 Get teacher By ID Response: $data");

      if (response.statusCode == 200 && data['res_code'] == 200) {
        return {
          "success": true,
          "message": data["response"] ?? "teacher fetched successfully",
          "teacher": TeacherModel.fromJson(data['data'] ?? {}),
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch teacher",
          "teacher": null,
        };
      }
    } catch (e) {
      // print("❌ Get teacher By ID Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "teacher": null,
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET CLASSES (No Auth Required)
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getClasses() async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getClasses);

      // 👇 ADD THIS TO SEE THE ACTUAL URL
      // print("🌐 Requesting URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // 👇 ADD THIS TO SEE RAW RESPONSE
      // print("📄 Response Status: ${response.statusCode}");
      // print(
      //   "📄 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
      // );

      // Check if response is HTML
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        // print("❌ Received HTML instead of JSON!");
        return {
          "success": false,
          "message": "Server returned HTML instead of JSON. Check API URL.",
          "classes": [],
        };
      }

      final data = jsonDecode(response.body);

      // print("📥 Get Classes Response: $data");

      if (response.statusCode == 200 && data['res_code'] == 200) {
        return {
          "success": true,
          "message": data["response"] ?? "Classes fetched successfully",
          "classes": data['data'] ?? [],
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch classes",
          "classes": [],
        };
      }
    } catch (e) {
      // print("❌ Get Classes Error: $e");
      return {"success": false, "message": "Network error: $e", "classes": []};
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET TEACHER ATTENDANCE (May require auth - keep token optional)
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getTeacherAttendance({
    String? token,
    required String teacherId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getTeacherAttendance}/$teacherId',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add auth header only if token provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      final data = jsonDecode(response.body);

      // print("📥 Get teacher Attendance Response: $data");

      if (response.statusCode == 200 && data['res_code'] == 200) {
        return {
          "success": true,
          "message": data["response"] ?? "Attendance fetched successfully",
          "attendance": data['data'] ?? [],
          "stats": data['stats'] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch attendance",
          "attendance": [],
        };
      }
    } catch (e) {
      // print("❌ Get teacher Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": [],
      };
    }
  }
}
