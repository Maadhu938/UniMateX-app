class AttendanceModel {
  final String id;
  final String subject;
  final String subjectCode;
  final int totalClasses;
  final int attendedClasses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMarkedDate;

  const AttendanceModel({
    required this.id,
    required this.subject,
    required this.subjectCode,
    required this.totalClasses,
    required this.attendedClasses,
    required this.createdAt,
    required this.updatedAt,
    this.lastMarkedDate,
  });

  double get percentage =>
      totalClasses > 0 ? attendedClasses / totalClasses : 0;

  int get classesToSkipSafely {
    if (percentage < 0.85) return 0;
    int a = attendedClasses;
    int t = totalClasses;
    int count = 0;
    int maxIterations = 500;
    
    while (maxIterations-- > 0) {
      if ((t + 1) > 0 && (a / (t + 1)) < 0.85) break;
      t += 1;
      count += 1;
    }
    return count;
  }

  int get classesToReachSafeZone {
    if (percentage >= 0.85) return 0;
    int a = attendedClasses;
    int t = totalClasses;
    int count = 0;
    int maxIterations = 500;
    
    while (maxIterations-- > 0) {
      if (t > 0 && (a / t) >= 0.85) break;
      a += 1;
      t += 1;
      count += 1;
    }
    return count;
  }

  double get percentageIfMissed {
    if (totalClasses == 0) return 0.0;
    return attendedClasses / (totalClasses + 1);
  }

  double get percentageIfAttended {
    return (attendedClasses + 1) / (totalClasses + 1);
  }

  String get statusLabel {
    if (percentage < 0.75) return 'danger';
    if (percentage < 0.85) return 'warning';
    return 'safe';
  }

  factory AttendanceModel.fromDoc(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'] ?? '',
      totalClasses: data['totalClasses'] ?? 0,
      attendedClasses: data['attendedClasses'] ?? 0,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (lastMarkedDate != null) 'lastMarkedDate': lastMarkedDate,
    };
  }

  AttendanceModel copyWith({
    int? totalClasses,
    int? attendedClasses,
  }) {
    return AttendanceModel(
      id: id,
      subject: subject,
      subjectCode: subjectCode,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastMarkedDate: lastMarkedDate,
    );
  }
}
