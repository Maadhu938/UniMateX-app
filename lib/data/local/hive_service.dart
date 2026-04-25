import 'package:hive_flutter/hive_flutter.dart';

/// Hive initialization and box management
class HiveService {
  static const String attendanceBox = 'attendance_cache';
  static const String timetableBox = 'timetable_cache';

  /// Initialize Hive — call once at app start
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open boxes for caching
    await Hive.openBox<Map>(attendanceBox);
    await Hive.openBox<Map>(timetableBox);
  }

  /// Clear all cached data (e.g., on logout)
  static Future<void> clearAll() async {
    await Hive.box<Map>(attendanceBox).clear();
    await Hive.box<Map>(timetableBox).clear();
  }
}
