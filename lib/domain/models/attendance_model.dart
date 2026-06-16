class AttendanceModel {
  final String id;
  final String subject;
  final String subjectCode;
  final int totalClasses;
  final int attendedClasses;
  final double targetPercentage;
  final int? totalClassesInSemester;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMarkedDate;

  const AttendanceModel({
    required this.id,
    required this.subject,
    required this.subjectCode,
    required this.totalClasses,
    required this.attendedClasses,
    required this.targetPercentage,
    required this.totalClassesInSemester,
    required this.createdAt,
    required this.updatedAt,
    this.lastMarkedDate,
  });

  double get percentage =>
      totalClasses > 0 ? attendedClasses / totalClasses : 0;

  int get classesToSkipSafely {
    if (targetPercentage <= 0) return 0;
    final value = ((attendedClasses - targetPercentage * totalClasses) / targetPercentage).floor();
    return value < 0 ? 0 : value;
  }

  int get classesToReachSafeZone {
    if (targetPercentage >= 1) return 0;
    final value = ((targetPercentage * totalClasses - attendedClasses) / (1 - targetPercentage)).ceil();
    return value < 0 ? 0 : value;
  }

  double get percentageIfMissed {
    if (totalClasses == 0) return 0.0;
    return attendedClasses / (totalClasses + 1);
  }

  double get percentageIfAttended {
    return (attendedClasses + 1) / (totalClasses + 1);
  }

  String get statusLabel {
    final warningThreshold = (targetPercentage - 0.10).clamp(0.0, 1.0);
    if (percentage < warningThreshold) return 'danger';
    if (percentage < targetPercentage) return 'warning';
    return 'safe';
  }

  factory AttendanceModel.fromDoc(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'] ?? '',
      totalClasses: data['totalClasses'] ?? 0,
      attendedClasses: data['attendedClasses'] ?? 0,
      targetPercentage: (data['targetPercentage'] ?? 0.75).toDouble(),
      totalClassesInSemester: data['totalClassesInSemester'] as int?,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      lastMarkedDate: data['lastMarkedDate']?.toDate(),
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'subject': subject,
      'subjectCode': subjectCode,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'targetPercentage': targetPercentage,
      'totalClassesInSemester': totalClassesInSemester,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (lastMarkedDate != null) 'lastMarkedDate': lastMarkedDate,
    };
  }

  AttendanceModel copyWith({
    int? totalClasses,
    int? attendedClasses,
    double? targetPercentage,
    int? totalClassesInSemester,
  }) {
    return AttendanceModel(
      id: id,
      subject: subject,
      subjectCode: subjectCode,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      totalClassesInSemester: totalClassesInSemester ?? this.totalClassesInSemester,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastMarkedDate: lastMarkedDate,
    );
  }
}
