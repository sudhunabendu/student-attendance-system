// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/utils/constants.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';

class AttendanceService {
  // ══════════════════════════════════════════════════════════
  // MARK ATTENDANCE (Single Student)
  // ══════════════════════════════════════════════════════════
static Future<Map<String, dynamic>> markAttendance({
    required String token,
    required String studentId,
    String status = 'present',
    String? classId,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.markAttendance);

      final body = <String, dynamic>{
        "student_id": studentId,
      };

      if (classId != null && classId.isNotEmpty) {
        body["class_id"] = classId;
      }

      final response = await http.post(
        url,
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode(body),
      );

      print("Mark Attendance Request Body: $response");

      final data = jsonDecode(response.body);
      // print("Mark Attendance Response: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response data
        final attendanceData = data['data'];
        
        return {
          "success": data["success"] ?? true,
          "message": data["message"] ?? "Attendance marked",
          "alreadyMarked": data["message"]?.toString().toLowerCase().contains('already') ?? false,
          // Parsed attendance data
          "attendanceId": attendanceData?['attendance_id'],
          "classId": attendanceData?['class_id'],
          "studentName": attendanceData?['student_name'],
          "rollNumber": attendanceData?['roll_number'],
          "status": attendanceData?['status'] ?? status,
          "checkInTime": attendanceData?['check_in_time'],
          "date": attendanceData?['date'],
          // Raw data for reference
          "data": attendanceData,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Something went wrong",
          "data": null,
        };
      }
    } catch (e) {
      print("Mark Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "data": null,
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET TODAY'S ATTENDANCE
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getTodayAttendance({
    required String token,
    String? classId,
    String? section,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getTodayAttendance)
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      print("Get Today Attendance Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList = data['data'] ?? data['attendance'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Attendance fetched",
          "attendance": AttendanceModel.fromJsonList(attendanceList),
          "stats": data["stats"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch attendance",
          "attendance": <AttendanceModel>[],
        };
      }
    } catch (e) {
      print("Get Today Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": <AttendanceModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE BY DATE
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAttendanceByDate({
    required String token,
    required String date,
    String? classId,
    String? section,
  }) async {
    try {
      final queryParams = <String, String>{
        'date': date,
      };
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getAttendance)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      print("Get Attendance By Date Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList = data['data'] ?? data['attendance'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Attendance fetched",
          "attendance": AttendanceModel.fromJsonList(attendanceList),
          "stats": data["stats"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch attendance",
          "attendance": <AttendanceModel>[],
        };
      }
    } catch (e) {
      print("Get Attendance By Date Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": <AttendanceModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE HISTORY
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAttendanceHistory({
    required String token,
    String? startDate,
    String? endDate,
    String? classId,
    String? section,
    String? studentId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }
      if (studentId != null && studentId.isNotEmpty) {
        queryParams['student_id'] = studentId;
      }

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getAttendanceHistory)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      print("Get Attendance History Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList = data['data'] ?? data['attendance'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "History fetched",
          "attendance": AttendanceModel.fromJsonList(attendanceList),
          "pagination": data["pagination"],
          "stats": data["stats"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch history",
          "attendance": <AttendanceModel>[],
        };
      }
    } catch (e) {
      print("Get Attendance History Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": <AttendanceModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENTS FOR ATTENDANCE
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getStudentsForAttendance({
    required String token,
    required String classId,
    String? section,
    String? date,
  }) async {
    try {
      final queryParams = <String, String>{
        'class_id': classId,
      };
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getStudentsForAttendance)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      print("Get Students For Attendance Response: $data");

      if (response.statusCode == 200) {
        final List<dynamic> studentsList = data['data'] ?? data['students'] ?? [];
        return {
          "success": true,
          "message": data["message"] ?? "Students fetched",
          "students": StudentModel.fromJsonList(studentsList),
          "alreadyMarked": data["alreadyMarked"] ?? [],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch students",
          "students": <StudentModel>[],
        };
      }
    } catch (e) {
      print("Get Students For Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "students": <StudentModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE STATS
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAttendanceStats({
    required String token,
    String? classId,
    String? section,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.getAttendanceStats)
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      print("Get Attendance Stats Response: $data");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Stats fetched",
          "stats": data["data"] ?? data["stats"] ?? {},
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch stats",
          "stats": {},
        };
      }
    } catch (e) {
      print("Get Attendance Stats Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "stats": {},
      };
    }
  }
}