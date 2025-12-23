// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../app/utils/constants.dart';
import '../models/teacher_attendance_model.dart';
import '../models/teacher_attendance_response_model.dart';
import '../models/teacher_model.dart';

class TeacherAttendanceService {
  // ══════════════════════════════════════════════════════════
  // MARK ATTENDANCE (Single Teacher) - FIXED
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> markAttendance({
    // required String token,
    required String teacherId,
    String status = 'present',
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.markAttendance);

      final body = <String, dynamic>{"teacher_id": teacherId};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Parse model (includes action)
        final TeacherAttendanceResponseModel? attendance =
            TeacherAttendanceResponseModel.fromApiResponse(data);

        final bool alreadyMarked =
            data["message"]?.toString().toLowerCase().contains('already') ??
            false;

        return {
          "success": data["success"] ?? true,
          "message": data["message"] ?? "Attendance updated",
          "alreadyMarked": alreadyMarked,

          // ---- ACTION ----
          "action": attendance?.action, // check_in / check_out
          // ---- teacher ----
          "attendanceId": attendance?.attendanceId,
          "teacherId": attendance?.teacherId,
          "teacherName": attendance?.fullName,
          "firstName": attendance?.firstName,
          "lastName": attendance?.lastName,
          // "rollNumber": attendance?.rollNumber,
          "email": attendance?.email,

          // ---- CLASS ----
          "classId": attendance?.classId,
          "className": attendance?.className,

          // ---- ATTENDANCE ----
          "status": attendance?.status ?? status,
          "checkInTime": attendance?.checkInTime,
          "checkOutTime": attendance?.checkOutTime,
          "formattedCheckInTime": attendance?.formattedCheckInTime,
          "formattedDate": attendance?.formattedDate,

          // ---- FULL OBJECT ----
          "attendanceRecord": attendance,

          // ---- RAW ----
          "data": data['data'],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to mark attendance",
          "error": data["error"],
          "attendanceRecord": null,
          "data": null,
        };
      }
    } catch (e, stackTrace) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}",
        "attendanceRecord": null,
        "data": null,
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // MARK ATTENDANCE WITH MODEL RETURN
  // ══════════════════════════════════════════════════════════
  static Future<AttendanceResult> markAttendanceWithModel({
    required String token,
    required String teacherId,
    String status = 'present',
    String? classId,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.markAttendance);

      final body = <String, dynamic>{"teacher_id": teacherId};

      if (classId != null && classId.isNotEmpty) {
        body["class_id"] = classId;
      }

      // debugPrint("📤 Mark Attendance Request: $body");

      final response = await http.post(
        url,
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      // debugPrint("📥 Mark Attendance Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendanceResponse = TeacherAttendanceResponseModel.fromApiResponse(
          data,
        );
        final bool alreadyMarked =
            data["message"]?.toString().toLowerCase().contains('already') ??
            false;

        return AttendanceResult(
          success: data["success"] ?? true,
          message: data["message"] ?? "Attendance marked",
          alreadyMarked: alreadyMarked,
          attendance: attendanceResponse,
        );
      } else {
        return AttendanceResult(
          success: false,
          message: data["message"] ?? "Something went wrong",
          error: data["error"]?.toString(),
        );
      }
    } catch (e) {
      // debugPrint("❌ Mark Attendance Error: $e");
      return AttendanceResult(
        success: false,
        message: "Network error: ${e.toString()}",
        error: e.toString(),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // MARK BULK ATTENDANCE
  // ══════════════════════════════════════════════════════════
  static Future<BulkAttendanceResult> markBulkAttendance({
    required String token,
    required String classId,
    required List<Map<String, dynamic>> attendanceList,
  }) async {
    try {
      final url = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.markBulkAttendance,
      );

      final body = {"class_id": classId, "attendance": attendanceList};

      debugPrint(
        "📤 Bulk Attendance Request: ${attendanceList.length} teachers",
      );

      final response = await http.post(
        url,
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      debugPrint("📥 Bulk Attendance Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> successList = data['data']?['success'] ?? [];
        final List<dynamic> failedList = data['data']?['failed'] ?? [];

        return BulkAttendanceResult(
          success: data["success"] ?? true,
          message: data["message"] ?? "Bulk attendance marked",
          successCount: successList.length,
          failedCount: failedList.length,
          successRecords: successList
              .map((json) => TeacherAttendanceResponseModel.fromJson(json))
              .toList(),
          failedRecords: failedList,
        );
      } else {
        return BulkAttendanceResult(
          success: false,
          message: data["message"] ?? "Failed to mark bulk attendance",
          error: data["error"]?.toString(),
        );
      }
    } catch (e) {
      debugPrint("❌ Bulk Attendance Error: $e");
      return BulkAttendanceResult(
        success: false,
        message: "Network error: ${e.toString()}",
        error: e.toString(),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET TODAY'S ATTENDANCE - FIXED
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getTodayAttendance({
    // required String token,
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

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getTodayAttendance,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      debugPrint("📤 Get Today Attendance: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json', // ✅ THIS WAS MISSING!
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      debugPrint("📥 Today Attendance Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList =
            data['data'] ?? data['attendance'] ?? [];

        // Parse attendance records
        final records = attendanceList
            .map((json) => TeacherAttendanceResponseModel.fromJson(json))
            .toList();

        return {
          "success": true,
          "message": data["message"] ?? "Attendance fetched",
          "attendance": TeacherAttendanceModel.fromJsonList(attendanceList),
          "attendanceRecords": records,
          "stats": _parseStats(data["stats"]),
          "count": records.length,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to fetch attendance",
          "attendance": <TeacherAttendanceModel>[],
          "attendanceRecords": <TeacherAttendanceResponseModel>[],
        };
      }
    } catch (e) {
      debugPrint("❌ Get Today Attendance Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "attendance": <TeacherAttendanceModel>[],
        "attendanceRecords": <TeacherAttendanceResponseModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE BY DATE - FIXED
  // ══════════════════════════════════════════════════════════
  static Future<AttendanceListResult> getAttendanceByDate({
    required String token,
    required String date,
    String? classId,
    String? section,
  }) async {
    try {
      final queryParams = <String, String>{'date': date};
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getAttendance,
      ).replace(queryParameters: queryParams);

      debugPrint("📤 Get Attendance By Date: $uri");

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      debugPrint("📥 Attendance By Date Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList =
            data['data'] ?? data['attendance'] ?? [];

        return AttendanceListResult(
          success: true,
          message: data["message"] ?? "Attendance fetched",
          records: attendanceList
              .map((json) => TeacherAttendanceResponseModel.fromJson(json))
              .toList(),
          stats: AttendanceStats.fromJson(data["stats"] ?? {}),
        );
      } else {
        return AttendanceListResult(
          success: false,
          message: data["message"] ?? "Failed to fetch attendance",
        );
      }
    } catch (e) {
      debugPrint("❌ Get Attendance By Date Error: $e");
      return AttendanceListResult(success: false, message: "Network error: $e");
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE HISTORY - FIXED
  // ══════════════════════════════════════════════════════════

  static Future<AttendanceHistoryResult> getAttendanceHistory({
    String? startDate,
    String? endDate,
    String? classId,
    String? section,
    String? teacherId,
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
      if (teacherId != null && teacherId.isNotEmpty) {
        queryParams['teacher_id'] = teacherId;
      }

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getTodayAttendance,
      ).replace(queryParameters: queryParams);

      debugPrint("📤 Get Attendance History: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // ✅ Safe JSON decode
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return AttendanceHistoryResult(
          success: false,
          message: "Invalid JSON response",
        );
      }

      debugPrint("📥 Attendance History Response: $data");

      final int resCode = data['res_code'] ?? response.statusCode;

      if (resCode == 200) {
        final List<dynamic> attendanceList = data['data'] ?? [];

        // ✅ Parse each record with error handling
        final records = <TeacherAttendanceResponseModel>[];
        for (var json in attendanceList) {
          try {
            records.add(TeacherAttendanceResponseModel.fromJson(json));
          } catch (e) {
            debugPrint("⚠️ Failed to parse record: $e");
            // Continue parsing other records
          }
        }

        return AttendanceHistoryResult(
          success: true,
          message: data['response'] ?? 'History fetched',
          records: records,
        );
      } else {
        return AttendanceHistoryResult(
          success: false,
          message: data['response'] ?? 'Failed to fetch history',
        );
      }
    } catch (e) {
      debugPrint("❌ Get Attendance History Error: $e");
      return AttendanceHistoryResult(
        success: false,
        message: "Network error: $e",
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET STUDENTS FOR ATTENDANCE
  // ══════════════════════════════════════════════════════════
  static Future<TeachersForAttendanceResult> getTeachersForAttendance({
    required String token,
    required String classId,
    String? section,
    String? date,
  }) async {
    try {
      final queryParams = <String, String>{'class_id': classId};
      if (section != null && section.isNotEmpty && section != 'All') {
        queryParams['section'] = section;
      }
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getTeachersForAttendance,
      ).replace(queryParameters: queryParams);

      debugPrint("📤 Get Teachers For Attendance: $uri");

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      debugPrint("📥 Teachers For Attendance Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> teachersList =
            data['data'] ?? data['teachers'] ?? [];
        final List<dynamic> alreadyMarkedList = data['alreadyMarked'] ?? [];

        // Parse already marked student IDs
        final Set<String> markedStudentIds = alreadyMarkedList
            .map(
              (item) => item is Map
                  ? item['student_id']?.toString() ??
                        item['studentId']?.toString()
                  : item.toString(),
            )
            .whereType<String>()
            .toSet();

        // Parse students and mark those already marked
        final teachers = teachersList.map((json) {
          final teacher = TeacherModel.fromJson(json);
          final isMarked = markedStudentIds.contains(teacher.id);
          return teacher.copyWith(
            isMarkedOnServer: isMarked,
            isPresent: isMarked,
          );
        }).toList();

        return TeachersForAttendanceResult(
          success: true,
          message: data["message"] ?? "teachers fetched",
          teachers: teachers,
          alreadyMarkedIds: markedStudentIds.toList(),
          totalCount: teachers.length,
          markedCount: markedStudentIds.length,
        );
      } else {
        return TeachersForAttendanceResult(
          success: false,
          message: data["message"] ?? "Failed to fetch students",
        );
      }
    } catch (e) {
      debugPrint("❌ Get Students For Attendance Error: $e");
      return TeachersForAttendanceResult(
        success: false,
        message: "Network error: $e",
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET ATTENDANCE STATS
  // ══════════════════════════════════════════════════════════
  static Future<AttendanceStatsResult> getAttendanceStats({
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

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getAttendanceStats,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      debugPrint("📤 Get Attendance Stats: $uri");

      final response = await http.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);
      debugPrint("📥 Attendance Stats Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return AttendanceStatsResult(
          success: true,
          message: data["message"] ?? "Stats fetched",
          stats: AttendanceStats.fromJson(data["data"] ?? data["stats"] ?? {}),
        );
      } else {
        return AttendanceStatsResult(
          success: false,
          message: data["message"] ?? "Failed to fetch stats",
        );
      }
    } catch (e) {
      debugPrint("❌ Get Attendance Stats Error: $e");
      return AttendanceStatsResult(
        success: false,
        message: "Network error: $e",
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════
  static Map<String, dynamic> _parseStats(dynamic stats) {
    if (stats == null) return {};
    if (stats is Map<String, dynamic>) return stats;
    return {};
  }
}

// ══════════════════════════════════════════════════════════
// RESULT CLASSES
// ══════════════════════════════════════════════════════════

/// Result for single attendance marking
class AttendanceResult {
  final bool success;
  final String message;
  final bool alreadyMarked;
  final TeacherAttendanceResponseModel? attendance;
  final String? error;

  AttendanceResult({
    required this.success,
    required this.message,
    this.alreadyMarked = false,
    this.attendance,
    this.error,
  });

  @override
  String toString() =>
      'AttendanceResult(success: $success, message: $message, '
      'alreadyMarked: $alreadyMarked, attendance: $attendance)';
}

/// Result for bulk attendance marking
class BulkAttendanceResult {
  final bool success;
  final String message;
  final int successCount;
  final int failedCount;
  final List<TeacherAttendanceResponseModel> successRecords;
  final List<dynamic> failedRecords;
  final String? error;

  BulkAttendanceResult({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.failedCount = 0,
    this.successRecords = const [],
    this.failedRecords = const [],
    this.error,
  });

  int get totalCount => successCount + failedCount;
  bool get hasFailures => failedCount > 0;
}

/// Result for attendance list queries
class AttendanceListResult {
  final bool success;
  final String message;
  final List<TeacherAttendanceResponseModel> records;
  final AttendanceStats? stats;
  final String? error;

  AttendanceListResult({
    required this.success,
    required this.message,
    this.records = const [],
    this.stats,
    this.error,
  });

  int get presentCount => records.where((r) => r.isPresent).length;
  int get absentCount => records.where((r) => r.isAbsent).length;
  int get lateCount => records.where((r) => r.isLate).length;
}

/// Result for attendance history
class AttendanceHistoryResult {
  final bool success;
  final String message;
  final List<TeacherAttendanceResponseModel> records;
  final PaginationInfo? pagination;
  final AttendanceStats? stats;
  final String? error;

  AttendanceHistoryResult({
    required this.success,
    required this.message,
    this.records = const [],
    this.pagination,
    this.stats,
    this.error,
  });

  bool get hasMore => pagination?.hasMore ?? false;
}

/// Result for students for attendance
class TeachersForAttendanceResult {
  final bool success;
  final String message;
  final List<TeacherModel> teachers;
  final List<String> alreadyMarkedIds;
  final int totalCount;
  final int markedCount;
  final String? error;

  TeachersForAttendanceResult({
    required this.success,
    required this.message,
    this.teachers = const [],
    this.alreadyMarkedIds = const [],
    this.totalCount = 0,
    this.markedCount = 0,
    this.error,
  });

  int get unmarkedCount => totalCount - markedCount;
  List<TeacherModel> get unmarkedTeachers =>
      teachers.where((s) => !s.isMarkedOnServer).toList();
}

/// Result for attendance stats
class AttendanceStatsResult {
  final bool success;
  final String message;
  final AttendanceStats? stats;
  final String? error;

  AttendanceStatsResult({
    required this.success,
    required this.message,
    this.stats,
    this.error,
  });
}

/// Attendance statistics model
class AttendanceStats {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double attendancePercentage;

  AttendanceStats({
    this.totalStudents = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.attendancePercentage = 0.0,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    final total =
        json['total_students'] ?? json['totalStudents'] ?? json['total'] ?? 0;
    final present =
        json['present_count'] ?? json['presentCount'] ?? json['present'] ?? 0;
    final absent =
        json['absent_count'] ?? json['absentCount'] ?? json['absent'] ?? 0;
    final late = json['late_count'] ?? json['lateCount'] ?? json['late'] ?? 0;
    final excused =
        json['excused_count'] ?? json['excusedCount'] ?? json['excused'] ?? 0;

    double percentage =
        json['attendance_percentage'] ??
        json['attendancePercentage'] ??
        json['percentage'] ??
        0.0;

    // Calculate if not provided
    if (percentage == 0 && total > 0) {
      percentage = ((present + late) / total) * 100;
    }

    return AttendanceStats(
      totalStudents: total is int ? total : int.tryParse(total.toString()) ?? 0,
      presentCount: present is int
          ? present
          : int.tryParse(present.toString()) ?? 0,
      absentCount: absent is int
          ? absent
          : int.tryParse(absent.toString()) ?? 0,
      lateCount: late is int ? late : int.tryParse(late.toString()) ?? 0,
      excusedCount: excused is int
          ? excused
          : int.tryParse(excused.toString()) ?? 0,
      attendancePercentage: percentage is double
          ? percentage
          : double.tryParse(percentage.toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_students': totalStudents,
    'present_count': presentCount,
    'absent_count': absentCount,
    'late_count': lateCount,
    'excused_count': excusedCount,
    'attendance_percentage': attendancePercentage,
  };

  @override
  String toString() =>
      'AttendanceStats(total: $totalStudents, present: $presentCount, '
      'absent: $absentCount, late: $lateCount, percentage: ${attendancePercentage.toStringAsFixed(1)}%)';
}

/// Pagination info model
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasMore;

  PaginationInfo({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 50,
    this.hasMore = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    final current =
        json['current_page'] ?? json['currentPage'] ?? json['page'] ?? 1;
    final total =
        json['total_pages'] ?? json['totalPages'] ?? json['pages'] ?? 1;
    final items =
        json['total_items'] ?? json['totalItems'] ?? json['total'] ?? 0;
    final perPage =
        json['items_per_page'] ?? json['itemsPerPage'] ?? json['limit'] ?? 50;

    return PaginationInfo(
      currentPage: current is int
          ? current
          : int.tryParse(current.toString()) ?? 1,
      totalPages: total is int ? total : int.tryParse(total.toString()) ?? 1,
      totalItems: items is int ? items : int.tryParse(items.toString()) ?? 0,
      itemsPerPage: perPage is int
          ? perPage
          : int.tryParse(perPage.toString()) ?? 50,
      hasMore: json['has_more'] ?? json['hasMore'] ?? (current < total),
    );
  }

  @override
  String toString() =>
      'PaginationInfo(page: $currentPage/$totalPages, total: $totalItems)';
}
