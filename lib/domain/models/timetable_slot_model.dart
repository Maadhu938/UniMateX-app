class TimetableSlotModel {
  final String id;
  final String subjectId;
  final int dayOfWeek;
  final int startMinutes;
  final int endMinutes;
  final String room;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimetableSlotModel({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    required this.room,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimetableSlotModel.fromMap(Map<String, dynamic> data) {
    return TimetableSlotModel(
      id: data['id'] ?? '',
      subjectId: data['subjectId'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? 1,
      startMinutes: data['startMinutes'] ?? 0,
      endMinutes: data['endMinutes'] ?? 0,
      room: data['room'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'dayOfWeek': dayOfWeek,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'room': room,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TimetableSlotModel copyWith({
    String? subjectId,
    int? dayOfWeek,
    int? startMinutes,
    int? endMinutes,
    String? room,
  }) {
    return TimetableSlotModel(
      id: id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      room: room ?? this.room,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
