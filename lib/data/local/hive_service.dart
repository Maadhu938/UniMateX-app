import 'package:hive_flutter/hive_flutter.dart';

/// Hive initialization and box management
class HiveService {
  static const String attendanceBox = 'attendance_cache';
  static const String timetableBox = 'timetable_cache';
  static const String subjectsBox = 'subjects_v2';
  static const String timetableSlotsBox = 'timetable_slots_v2';
  static const String attendanceRecordsBox = 'attendance_records_v2';
  static const String metaBox = 'meta_v2';

  /// Initialize Hive — call once at app start
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open boxes for caching
    await Hive.openBox<Map>(attendanceBox);
    await Hive.openBox<Map>(timetableBox);
    await Hive.openBox<Map>(subjectsBox);
    await Hive.openBox<Map>(timetableSlotsBox);
    await Hive.openBox<Map>(attendanceRecordsBox);
    await Hive.openBox<Map>(metaBox);
  }

  /// Clear all cached data (e.g., on logout)
  static Future<void> clearAll() async {
    await Hive.box<Map>(attendanceBox).clear();
    await Hive.box<Map>(timetableBox).clear();
    await Hive.box<Map>(subjectsBox).clear();
    await Hive.box<Map>(timetableSlotsBox).clear();
    await Hive.box<Map>(attendanceRecordsBox).clear();
    await Hive.box<Map>(metaBox).clear();
  }
}
