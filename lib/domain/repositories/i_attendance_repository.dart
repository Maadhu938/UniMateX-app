import '../models/attendance_model.dart';

/// Abstract interface — domain layer has zero Firestore/Hive knowledge
abstract class IAttendanceRepository {
  /// Live stream from Firestore (caches to Hive on each emission)
  Stream<List<AttendanceModel>> watchAttendance(String userId);

  /// Offline-first: returns Hive cache, syncs Firestore in background
  Future<List<AttendanceModel>> getOfflineFirst(String userId);

  /// Mark a class as attended/absent — writes to Firestore
  Future<void> markClass({
    required String userId,
    required String subjectId,
    required bool attended,
  });

  /// Mark attendance for a timetable slot on a specific date
  Future<void> markSlot({
    required String userId,
    required String slotId,
    required bool attended,
    DateTime? date,
  });

  /// Returns marked slots for a date: slotId -> true(present) / false(absent)
  Future<Map<String, bool>> getSlotMarksForDate({
    required String userId,
    required DateTime date,
  });

  /// Add a new subject to track attendance
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  });

  /// Update subject-level attendance settings.
  Future<void> updateSubjectSettings({
    required String userId,
    required String subjectId,
    double? targetPercentage,
    int? totalClassesInSemester,
    bool clearSemesterTotal = false,
  });

  /// Delete a subject's attendance record
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  });
}
