// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app/utils/constants.dart';

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // POST Request
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on HttpException {
      return {'error': 'Server error occurred'};
    } catch (e) {
      return {'error': 'Something went wrong: $e'};
    }
  }

  // GET Request
  Future<Map<String, dynamic>> get({
    required String endpoint,
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'error': 'No internet connection'};
    } on HttpException {
      return {'error': 'Server error occurred'};
    } catch (e) {
      return {'error': 'Something went wrong: $e'};
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'error': 'No internet connection'};
    } on HttpException {
      return {'error': 'Server error occurred'};
    } catch (e) {
      return {'error': 'Something went wrong: $e'};
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'error': 'No internet connection'};
    } on HttpException {
      return {'error': 'Server error occurred'};
    } catch (e) {
      return {'error': 'Something went wrong: $e'};
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'error': body['message'] ?? body['response'] ?? 'Request failed',
          'res_code': response.statusCode,
        };
      }
    } catch (e) {
      return {'error': 'Failed to parse response'};
    }
  }
}