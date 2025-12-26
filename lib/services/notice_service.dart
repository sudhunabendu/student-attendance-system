import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notice_model.dart';
import '../app/utils/constants.dart';

class NoticeService {
  // ══════════════════════════════════════════════════════════
  // GET ALL NOTICES
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getAllNotice({
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

      if (classId != null && classId.isNotEmpty) {
        queryParams['classId'] = classId;
      }
      if (section != null && section.isNotEmpty) {
        queryParams['section'] = section;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.getNotices,
      ).replace(queryParameters: queryParams);

      debugPrint("📡 Calling API: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint("📥 Response Status: ${response.statusCode}");

      // ✅ Check for HTML response
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        debugPrint("❌ Received HTML instead of JSON!");
        return {
          "success": false,
          "message": "Server returned HTML. Check API URL.",
          "notices": <NoticeModel>[],
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['res_code'] == 200) {
        final List<dynamic> noticeList = data['data'] ?? [];

        debugPrint("✅ Fetched ${noticeList.length} notices from API");

        // ✅ Parse notices with error handling
        List<NoticeModel> notices = [];
        for (var i = 0; i < noticeList.length; i++) {
          try {
            notices.add(NoticeModel.fromJson(noticeList[i]));
          } catch (e) {
            debugPrint("❌ Error parsing notice $i: $e");
          }
        }

        return {
          "success": true,
          "message": data["response"] ?? "Notices fetched successfully",
          "notices": notices,
          "pagination": data['pagination'] ?? {
            'page': page,
            'limit': limit,
            'total': noticeList.length,
            'totalPages': 1,
          },
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch notices",
          "notices": <NoticeModel>[],
        };
      }
    } catch (e) {
      debugPrint("❌ Get Notices Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "notices": <NoticeModel>[],
      };
    }
  }

  // ══════════════════════════════════════════════════════════
  // GET NOTICE BY ID
  // ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getNoticeById(String noticeId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getNotices}/$noticeId',
      );

      debugPrint("📡 Fetching Notice: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['res_code'] == 200) {
        return {
          "success": true,
          "message": data["response"] ?? "Notice fetched successfully",
          "notice": NoticeModel.fromJson(data['data']),
        };
      } else {
        return {
          "success": false,
          "message": data["response"] ?? "Failed to fetch notice",
          "notice": null,
        };
      }
    } catch (e) {
      debugPrint("❌ Get Notice Error: $e");
      return {
        "success": false,
        "message": "Network error: $e",
        "notice": null,
      };
    }
  }
}