import 'dart:convert';

class TeacherQRHelper {
  /// Parse QR code and extract student ID
  /// Returns a map with parsed data or null if invalid
  static Map<String, dynamic>? parseQRCode(String code) {
    if (code.isEmpty) return null;

    try {
      // Try JSON format
      if (code.trim().startsWith('{')) {
        final json = jsonDecode(code) as Map<String, dynamic>;
        final id = json['id']?.toString() ?? 
                   json['_id']?.toString() ?? 
                   json['teacherId']?.toString() ??
                   json['teacher_id']?.toString();
        
        if (id == null || id.isEmpty) return null;
        
        return {
          'id': id,
          'name': json['name']?.toString(),
          // 'rollNumber': json['rollNumber']?.toString() ?? json['roll_number']?.toString(),
          'isValid': _checkValidity(json),
        };
      }

      // Try pipe-separated: "id|name|rollNumber|timestamp"
      if (code.contains('|')) {
        final parts = code.split('|');
        if (parts.isEmpty || parts[0].isEmpty) return null;
        
        return {
          'id': parts[0].trim(),
          'name': parts.length > 1 ? parts[1].trim() : null,
          // 'rollNumber': parts.length > 2 ? parts[2].trim() : null,
          'isValid': parts.length > 3 ? _checkTimestamp(parts[3]) : true,
        };
      }

      // Try colon-separated: "STUDENT:id:timestamp"
      if (code.contains(':')) {
        final parts = code.split(':');
        String id;
        String? timestamp;
        
        if (parts[0].toUpperCase() == 'TEACHER' || parts[0].toUpperCase() == 'TEA') {
          if (parts.length < 2) return null;
          id = parts[1].trim();
          timestamp = parts.length > 2 ? parts[2] : null;
        } else {
          id = parts[0].trim();
          timestamp = parts.length > 1 ? parts[1] : null;
        }
        
        if (id.isEmpty) return null;
        
        return {
          'id': id,
          'isValid': timestamp != null ? _checkTimestamp(timestamp) : true,
        };
      }

      // Simple ID format
      return {
        'id': code.trim(),
        'isValid': true,
      };
    } catch (e) {
      print('QR parse error: $e');
      return null;
    }
  }

  /// Check if QR is still valid based on JSON data
  static bool _checkValidity(Map<String, dynamic> json) {
    // Check expiresAt
    if (json['expiresAt'] != null || json['expires_at'] != null) {
      final expiresAt = DateTime.tryParse(
        (json['expiresAt'] ?? json['expires_at']).toString()
      );
      if (expiresAt != null) {
        return DateTime.now().isBefore(expiresAt);
      }
    }

    // Check generatedAt (24 hour validity)
    if (json['generatedAt'] != null || json['generated_at'] != null || json['timestamp'] != null) {
      DateTime? generatedAt;
      
      final ts = json['generatedAt'] ?? json['generated_at'] ?? json['timestamp'];
      if (ts is int) {
        generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      } else {
        generatedAt = DateTime.tryParse(ts.toString());
      }
      
      if (generatedAt != null) {
        final expiryTime = generatedAt.add(const Duration(hours: 24));
        return DateTime.now().isBefore(expiryTime);
      }
    }

    return true; // No timestamp, consider valid
  }

  /// Check timestamp validity (24 hours)
  static bool _checkTimestamp(String timestamp) {
    try {
      final ts = int.tryParse(timestamp);
      DateTime? generatedAt;
      
      if (ts != null) {
        generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      } else {
        generatedAt = DateTime.tryParse(timestamp);
      }
      
      if (generatedAt != null) {
        final expiryTime = generatedAt.add(const Duration(hours: 24));
        return DateTime.now().isBefore(expiryTime);
      }
      
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Generate QR code string for a student
  static String generateQRString({
    required String teacherId,
    String? name,
    // String? rollNumber,
    // String? className,
    // String? section,
  }) {
    return jsonEncode({
      'id': teacherId,
      if (name != null) 'name': name,
      // if (rollNumber != null) 'rollNumber': rollNumber,
      // if (className != null) 'className': className,
      // if (section != null) 'section': section,
      'generatedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }
}