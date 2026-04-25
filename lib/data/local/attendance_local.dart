import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/attendance_model.dart';
import 'hive_service.dart';

/// Read-cache for attendance data — populated from Firestore snapshots() stream
class AttendanceLocal {
  Box<Map> get _box => Hive.box<Map>(HiveService.attendanceBox);

  /// Save attendance list to Hive (called when Firestore stream emits)
  Future<void> save(List<AttendanceModel> data) async {
    final map = <String, Map>{};
    for (final item in data) {
      map[item.id] = {
        'id': item.id,
        'subject': item.subject,
        'subjectCode': item.subjectCode,
        'totalClasses': item.totalClasses,
        'attendedClasses': item.attendedClasses,
        'createdAt': item.createdAt.toIso8601String(),
        'updatedAt': item.updatedAt.toIso8601String(),
      };
    }
    await _box.clear();
    await _box.putAll(map);
  }

  /// Get cached attendance data
  Future<List<AttendanceModel>> get() async {
    return _box.values.map((raw) {
      final data = Map<String, dynamic>.from(raw);
      return AttendanceModel(
        id: data['id'] ?? '',
        subject: data['subject'] ?? '',
        subjectCode: data['subjectCode'] ?? '',
        totalClasses: data['totalClasses'] ?? 0,
        attendedClasses: data['attendedClasses'] ?? 0,
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}
