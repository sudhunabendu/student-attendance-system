// lib/models/qr_data_model.dart

import 'dart:convert';

class TeacherQRData {
  final String id;
  final String? name;
  // final String? rollNumber;
  // final String? className;
  // final String? section;
  final DateTime? generatedAt;
  final DateTime? expiresAt;

  TeacherQRData({
    required this.id,
    this.name,
    // this.rollNumber,
    // this.className,
    // this.section,
    this.generatedAt,
    this.expiresAt,
  });

  /// Check if QR code is still valid (within 24 hours)
  bool get isValid {
    if (expiresAt != null) {
      return DateTime.now().isBefore(expiresAt!);
    }
    if (generatedAt != null) {
      final expiryTime = generatedAt!.add(const Duration(hours: 24));
      return DateTime.now().isBefore(expiryTime);
    }
    // If no timestamp, consider it valid
    return true;
  }

  /// Check if expired
  bool get isExpired => !isValid;

  /// Parse QR code string to QRData object
  /// Supports multiple formats:
  /// 1. JSON: {"id": "123", "name": "John", ...}
  /// 2. Simple ID: "STU123"
  /// 3. Pipe separated: "id|name|rollNumber|className|section|timestamp"
  /// 4. Colon separated: "STUDENT:id:timestamp"
  static TeacherQRData? parse(String code) {
    if (code.isEmpty) return null;

    try {
      // Try JSON format first
      if (code.trim().startsWith('{')) {
        return _parseJson(code);
      }

      // Try pipe-separated format
      if (code.contains('|')) {
        return _parsePipeSeparated(code);
      }

      // Try colon-separated format
      if (code.contains(':')) {
        return _parseColonSeparated(code);
      }

      // Assume it's a simple student ID
      return TeacherQRData(id: code.trim());
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  /// Parse JSON format QR code
  static TeacherQRData? _parseJson(String code) {
    try {
      final Map<String, dynamic> json = jsonDecode(code);
      
      // Extract ID from various possible field names
      final id = json['id']?.toString() ?? 
                 json['_id']?.toString() ?? 
                 json['teacherId']?.toString() ??
                 json['teacher_id']?.toString();
      
      if (id == null || id.isEmpty) return null;

      DateTime? generatedAt;
      DateTime? expiresAt;

      // Parse timestamps
      if (json['generatedAt'] != null) {
        generatedAt = DateTime.tryParse(json['generatedAt'].toString());
      } else if (json['generated_at'] != null) {
        generatedAt = DateTime.tryParse(json['generated_at'].toString());
      } else if (json['timestamp'] != null) {
        // Handle milliseconds timestamp
        final ts = json['timestamp'];
        if (ts is int) {
          generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
        } else {
          generatedAt = DateTime.tryParse(ts.toString());
        }
      }

      if (json['expiresAt'] != null) {
        expiresAt = DateTime.tryParse(json['expiresAt'].toString());
      } else if (json['expires_at'] != null) {
        expiresAt = DateTime.tryParse(json['expires_at'].toString());
      }

      return TeacherQRData(
        id: id,
        name: json['name']?.toString() ?? json['full_name']?.toString(),
        // rollNumber: json['rollNumber']?.toString() ?? 
        //             json['roll_number']?.toString() ??
        //             json['roleNumber']?.toString(),
        // className: json['className']?.toString() ?? json['class_name']?.toString(),
        // section: json['section']?.toString(),
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );
    } catch (e) {
      print('JSON parse error: $e');
      return null;
    }
  }

  /// Parse pipe-separated format: "id|name|rollNumber|className|section|timestamp"
  static TeacherQRData? _parsePipeSeparated(String code) {
    try {
      final parts = code.split('|');
      if (parts.isEmpty) return null;

      final id = parts[0].trim();
      if (id.isEmpty) return null;

      DateTime? generatedAt;
      if (parts.length > 5 && parts[5].isNotEmpty) {
        // Try parsing as milliseconds timestamp
        final ts = int.tryParse(parts[5]);
        if (ts != null) {
          generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
        } else {
          generatedAt = DateTime.tryParse(parts[5]);
        }
      }

      return TeacherQRData(
        id: id,
        name: parts.length > 1 ? parts[1].trim() : null,
        // rollNumber: parts.length > 2 ? parts[2].trim() : null,
        // className: parts.length > 3 ? parts[3].trim() : null,
        // section: parts.length > 4 ? parts[4].trim() : null,
        generatedAt: generatedAt,
      );
    } catch (e) {
      print('Pipe parse error: $e');
      return null;
    }
  }

  /// Parse colon-separated format: "STUDENT:id:timestamp" or "id:timestamp"
  static TeacherQRData? _parseColonSeparated(String code) {
    try {
      final parts = code.split(':');
      if (parts.isEmpty) return null;

      String id;
      DateTime? generatedAt;

      // Check if first part is a prefix like "TEACHER" or "TEA"
      if (parts[0].toUpperCase() == 'TEACHER' || 
          parts[0].toUpperCase() == 'TEA' ||
          parts[0].toUpperCase() == 'QR') {
        if (parts.length < 2) return null;
        id = parts[1].trim();
        
        if (parts.length > 2 && parts[2].isNotEmpty) {
          final ts = int.tryParse(parts[2]);
          if (ts != null) {
            generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
          }
        }
      } else {
        id = parts[0].trim();
        
        if (parts.length > 1 && parts[1].isNotEmpty) {
          final ts = int.tryParse(parts[1]);
          if (ts != null) {
            generatedAt = DateTime.fromMillisecondsSinceEpoch(ts);
          }
        }
      }

      if (id.isEmpty) return null;

      return TeacherQRData(id: id, generatedAt: generatedAt);
    } catch (e) {
      print('Colon parse error: $e');
      return null;
    }
  }

  /// Generate QR code data string (JSON format)
  String toQRString() {
    return jsonEncode({
      'id': id,
      if (name != null) 'name': name,
      // if (rollNumber != null) 'rollNumber': rollNumber,
      // if (className != null) 'className': className,
      // if (section != null) 'section': section,
      'generatedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  @override
  String toString() {
    return 'QRData(id: $id, name: $name, isValid: $isValid)';
  }
}