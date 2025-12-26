// import 'dart:convert';

// // Helper function to parse response from JSON string
// NoticeResponseModel noticeResponseFromJson(String str) =>
//     NoticeResponseModel.fromJson(json.decode(str));

// // Helper function to convert response to JSON string
// String noticeResponseToJson(NoticeResponseModel data) =>
//     json.encode(data.toJson());

// class NoticeResponseModel {
//   final int? resCode;
//   final String? response;
//   final List<NoticeModel>? data;

//   NoticeResponseModel({
//     this.resCode,
//     this.response,
//     this.data,
//   });

//   // Factory constructor to create NoticeResponseModel from JSON
//   factory NoticeResponseModel.fromJson(Map<String, dynamic> json) =>
//       NoticeResponseModel(
//         resCode: json["res_code"],
//         response: json["response"],
//         data: json["data"] != null
//             ? List<NoticeModel>.from(
//                 json["data"].map((x) => NoticeModel.fromJson(x)))
//             : null,
//       );

//   // Convert NoticeResponseModel to JSON
//   Map<String, dynamic> toJson() => {
//         "res_code": resCode,
//         "response": response,
//         "data": data != null
//             ? List<dynamic>.from(data!.map((x) => x.toJson()))
//             : null,
//       };

//   // Helper getters
//   bool get isSuccess => resCode == 200;
//   bool get hasData => data != null && data!.isNotEmpty;
//   int get noticeCount => data?.length ?? 0;

//   // Get only active notices
//   List<NoticeModel> get activeNotices =>
//       data?.where((notice) => notice.isActive).toList() ?? [];

//   @override
//   String toString() {
//     return 'NoticeResponseModel(resCode: $resCode, response: $response, dataCount: ${data?.length})';
//   }
// }

// class NoticeModel {
//   final String? id;
//   final String? title;
//   final String? fileName;
//   final String? fileUrl;
//   final String? fileType;
//   final int? fileSize;
//   final bool? isForAll;
//   final String? status;
//   final String? uploadedBy;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? version;

//   NoticeModel({
//     this.id,
//     this.title,
//     this.fileName,
//     this.fileUrl,
//     this.fileType,
//     this.fileSize,
//     this.isForAll,
//     this.status,
//     this.uploadedBy,
//     this.createdAt,
//     this.updatedAt,
//     this.version,
//   });

//   // Factory constructor to create NoticeModel from JSON
//   factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
//         id: json["_id"],
//         title: json["title"],
//         fileName: json["file_name"],
//         fileUrl: json["file_url"],
//         fileType: json["file_type"],
//         fileSize: json["file_size"],
//         isForAll: json["is_for_all"],
//         status: json["status"],
//         uploadedBy: json["uploaded_by"],
//         createdAt: json["createdAt"] != null
//             ? DateTime.parse(json["createdAt"])
//             : null,
//         updatedAt: json["updatedAt"] != null
//             ? DateTime.parse(json["updatedAt"])
//             : null,
//         version: json["__v"],
//       );

//   // Convert NoticeModel to JSON
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "title": title,
//         "file_name": fileName,
//         "file_url": fileUrl,
//         "file_type": fileType,
//         "file_size": fileSize,
//         "is_for_all": isForAll,
//         "status": status,
//         "uploaded_by": uploadedBy,
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//         "__v": version,
//       };

//   // CopyWith method for immutability
//   NoticeModel copyWith({
//     String? id,
//     String? title,
//     String? fileName,
//     String? fileUrl,
//     String? fileType,
//     int? fileSize,
//     bool? isForAll,
//     String? status,
//     String? uploadedBy,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     int? version,
//   }) {
//     return NoticeModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       fileName: fileName ?? this.fileName,
//       fileUrl: fileUrl ?? this.fileUrl,
//       fileType: fileType ?? this.fileType,
//       fileSize: fileSize ?? this.fileSize,
//       isForAll: isForAll ?? this.isForAll,
//       status: status ?? this.status,
//       uploadedBy: uploadedBy ?? this.uploadedBy,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       version: version ?? this.version,
//     );
//   }

//   // Helper getters
//   bool get isImage => fileType?.startsWith('image/') ?? false;
//   bool get isPdf => fileType == 'application/pdf';
//   bool get isActive => status == 'Active';

//   // Format file size to readable string
//   String get formattedFileSize {
//     if (fileSize == null) return '';
//     if (fileSize! < 1024) return '$fileSize B';
//     if (fileSize! < 1024 * 1024) {
//       return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
//     }
//     return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
//   }

//   @override
//   String toString() {
//     return 'NoticeModel(id: $id, title: $title, status: $status)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is NoticeModel && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }

class NoticeModel {
  final String id;
  final String title;
  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final bool isForAll;
  final String status;
  final String? uploadedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoticeModel({
    required this.id,
    required this.title,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.isForAll = true,
    this.status = 'Active',
    this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  // ══════════════════════════════════════════════════════════
  // FROM JSON
  // ══════════════════════════════════════════════════════════
  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fileName: json['file_name']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      fileSize: json['file_size'] is int
          ? json['file_size']
          : int.tryParse(json['file_size']?.toString() ?? ''),
      isForAll: json['is_for_all'] ?? true,
      status: json['status']?.toString() ?? 'Active',
      uploadedBy: json['uploaded_by']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  // ══════════════════════════════════════════════════════════
  // TO JSON
  // ══════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'is_for_all': isForAll,
      'status': status,
      'uploaded_by': uploadedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ══════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ══════════════════════════════════════════════════════════

  /// Check if notice has an attachment
  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;

  /// Check if file is an image
  bool get isImage => fileType?.startsWith('image/') ?? false;

  /// Check if file is a PDF
  bool get isPdf => fileType == 'application/pdf';

  /// Check if file is a document
  bool get isDocument =>
      (fileType?.contains('document') ?? false) ||
      (fileType?.contains('word') ?? false) ||
      (fileType?.contains('sheet') ?? false) ||
      (fileType?.contains('excel') ?? false);

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return '';

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get file extension
  String get fileExtension {
    if (fileName == null) return '';
    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  /// Check if notice is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Get formatted date
  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// Get formatted time
  String get formattedTime {
    if (createdAt == null) return '';
    final hour = createdAt!.hour;
    final minute = createdAt!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  /// Get relative time (e.g., "2 hours ago")
  String get relativeTime {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 30) {
      return formattedDate;
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // ══════════════════════════════════════════════════════════
  // COPY WITH
  // ══════════════════════════════════════════════════════════
  NoticeModel copyWith({
    String? id,
    String? title,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    bool? isForAll,
    String? status,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      isForAll: isForAll ?? this.isForAll,
      status: status ?? this.status,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NoticeModel(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoticeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ══════════════════════════════════════════════════════════
// NOTICE RESPONSE MODEL (For pagination)
// ══════════════════════════════════════════════════════════
class NoticeResponse {
  final bool success;
  final String message;
  final List<NoticeModel> notices;
  final PaginationModel? pagination;

  NoticeResponse({
    required this.success,
    required this.message,
    required this.notices,
    this.pagination,
  });

  factory NoticeResponse.fromJson(Map<String, dynamic> json) {
    return NoticeResponse(
      success: json['res_code'] == 200,
      message: json['response'] ?? '',
      notices:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NoticeModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
