class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String teacher;
  final double targetPercentage;
  final int? totalClassesInSemester;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teacher,
    required this.targetPercentage,
    required this.totalClassesInSemester,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> data) {
    return SubjectModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      teacher: data['teacher'] ?? '',
      targetPercentage: (data['targetPercentage'] ?? 0.75).toDouble(),
      totalClassesInSemester: data['totalClassesInSemester'] as int?,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'teacher': teacher,
      'targetPercentage': targetPercentage,
      'totalClassesInSemester': totalClassesInSemester,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SubjectModel copyWith({
    String? name,
    String? code,
    String? teacher,
    double? targetPercentage,
    int? totalClassesInSemester,
    bool clearSemesterTotal = false,
  }) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacher: teacher ?? this.teacher,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      totalClassesInSemester:
          clearSemesterTotal ? null : totalClassesInSemester ?? this.totalClassesInSemester,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
