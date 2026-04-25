import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/timetable_model.dart';
import 'hive_service.dart';

/// Read-cache for timetable data
class TimetableLocal {
  Box<Map> get _box => Hive.box<Map>(HiveService.timetableBox);

  Future<void> save(List<TimetableModel> data) async {
    final map = <String, Map>{};
    for (final item in data) {
      map[item.id] = {
        'id': item.id,
        'subject': item.subject,
        'subjectCode': item.subjectCode,
        'dayOfWeek': item.dayOfWeek,
        'startMinutes': item.startMinutes,
        'endMinutes': item.endMinutes,
        'room': item.room,
        'createdAt': item.createdAt.toIso8601String(),
        'updatedAt': item.updatedAt.toIso8601String(),
      };
    }
    await _box.clear();
    await _box.putAll(map);
  }

  Future<List<TimetableModel>> get() async {
    return _box.values.map((raw) {
      final data = Map<String, dynamic>.from(raw);
      return TimetableModel(
        id: data['id'] ?? '',
        subject: data['subject'] ?? '',
        subjectCode: data['subjectCode'] ?? '',
        dayOfWeek: data['dayOfWeek'] ?? 1,
        startMinutes: data['startMinutes'] ?? 0,
        endMinutes: data['endMinutes'] ?? 0,
        room: data['room'] ?? '',
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}
