enum AttendanceStatus {
  present,
  absent,
  cancelled,
}

class AttendanceRecordModel {
  final String id;
  final String slotId;
  final String subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRecordModel({
    required this.id,
    required this.slotId,
    required this.subjectId,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> data) {
    final rawStatus = data['status'] ?? 'present';
    final status = AttendanceStatus.values.firstWhere(
      (value) => value.name == rawStatus,
      orElse: () => AttendanceStatus.present,
    );

    return AttendanceRecordModel(
      id: data['id'] ?? '',
      slotId: data['slotId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      status: status,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slotId': slotId,
      'subjectId': subjectId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AttendanceRecordModel copyWith({
    String? slotId,
    String? subjectId,
    DateTime? date,
    AttendanceStatus? status,
  }) {
    return AttendanceRecordModel(
      id: id,
      slotId: slotId ?? this.slotId,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
