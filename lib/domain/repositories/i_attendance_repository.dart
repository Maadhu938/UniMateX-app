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

  /// Add a new subject to track attendance
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  });

  /// Delete a subject's attendance record
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  });
}
