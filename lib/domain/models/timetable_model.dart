class TimetableModel {
  final String id;
  final String subject;
  final String subjectCode;
  final int dayOfWeek; // 1=Mon ... 7=Sun
  final int startMinutes; // minutes from midnight (e.g., 540 = 9:00 AM)
  final int endMinutes; // minutes from midnight (e.g., 600 = 10:00 AM)
  final String room;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimetableModel({
    required this.id,
    required this.subject,
    required this.subjectCode,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    required this.room,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimetableModel.fromDoc(String id, Map<String, dynamic> data) {
    return TimetableModel(
      id: id,
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? 1,
      startMinutes: data['startMinutes'] ?? 0,
      endMinutes: data['endMinutes'] ?? 0,
      room: data['room'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'subject': subject,
      'subjectCode': subjectCode,
      'dayOfWeek': dayOfWeek,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'room': room,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Formatted time string e.g. "09:00 - 10:30"
  String get timeString {
    final startStr =
        '${(startMinutes ~/ 60).toString().padLeft(2, '0')}:${(startMinutes % 60).toString().padLeft(2, '0')}';
    final endStr =
        '${(endMinutes ~/ 60).toString().padLeft(2, '0')}:${(endMinutes % 60).toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  /// Calculate next occurrence of this class
  DateTime get nextOccurrence {
    final now = DateTime.now();
    var daysUntil = (dayOfWeek - now.weekday) % 7;
    if (daysUntil == 0 && now.hour * 60 + now.minute >= startMinutes) {
      daysUntil = 7; // already passed today, schedule next week
    }
    final nextDate = now.add(Duration(days: daysUntil));
    return DateTime(nextDate.year, nextDate.month, nextDate.day,
        startMinutes ~/ 60, startMinutes % 60);
  }

  /// Day name abbreviation
  String get dayName {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek.clamp(1, 7)];
  }

  TimetableModel copyWith({
    String? subject,
    String? subjectCode,
    int? dayOfWeek,
    int? startMinutes,
    int? endMinutes,
    String? room,
  }) {
    return TimetableModel(
      id: id,
      subject: subject ?? this.subject,
      subjectCode: subjectCode ?? this.subjectCode,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      room: room ?? this.room,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
