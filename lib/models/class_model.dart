// // lib/models/class_model.dart

// class ClassModel {
//   final String id;
//   final String name;
//   final String? section;
//   final String? description;
//   final String? teacherId;
//   final int? studentCount;
//   final String? status;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   ClassModel({
//     required this.id,
//     required this.name,
//     this.section,
//     this.description,
//     this.teacherId,
//     this.studentCount,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory ClassModel.fromJson(Map<String, dynamic> json) {
//     return ClassModel(
//       id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
//       name: json['name']?.toString() ?? json['class_name']?.toString() ?? '',
//       section: json['section']?.toString(),
//       description: json['description']?.toString(),
//       teacherId: json['teacher_id']?.toString(),
//       studentCount: json['student_count'] ?? json['studentCount'],
//       status: json['status']?.toString(),
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'].toString())
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'].toString())
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'section': section,
//       'description': description,
//       'teacher_id': teacherId,
//       'student_count': studentCount,
//       'status': status,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }

//   static List<ClassModel> fromJsonList(List<dynamic> jsonList) {
//     return jsonList
//         .map((json) => ClassModel.fromJson(json as Map<String, dynamic>))
//         .toList();
//   }

//   @override
//   String toString() => 'ClassModel(id: $id, name: $name, section: $section)';
// }

class ClassModel {
  final String id;
  final String name;
  final String code;
  final int level;
  final String category;
  final String description;
  final String status;
  final AgeGroup ageGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    required this.level,
    required this.category,
    required this.description,
    required this.status,
    required this.ageGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      level: json['level'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Active',
      ageGroup: AgeGroup.fromJson(json['ageGroup'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'level': level,
      'category': category,
      'description': description,
      'status': status,
      'ageGroup': ageGroup.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AgeGroup {
  final int min;
  final int max;

  AgeGroup({required this.min, required this.max});

  factory AgeGroup.fromJson(Map<String, dynamic> json) {
    return AgeGroup(
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}