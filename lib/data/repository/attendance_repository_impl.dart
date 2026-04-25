import '../../domain/models/attendance_model.dart';
import '../../domain/repositories/i_attendance_repository.dart';
import '../../core/errors/failures.dart';
import '../remote/attendance_remote.dart';
import '../local/attendance_local.dart';

class AttendanceRepositoryImpl implements IAttendanceRepository {
  final AttendanceRemote _remote;
  final AttendanceLocal _local;

  AttendanceRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<AttendanceModel>> watchAttendance(String userId) {
    return _remote.watchAll(userId).map((data) {
      // Cache to Hive on every Firestore emission
      _local.save(data);
      return data;
    });
  }

  @override
  Future<List<AttendanceModel>> getOfflineFirst(String userId) async {
    // Return Hive cache immediately
    final cached = await _local.get();

    // Sync from Firestore in background (fire-and-forget)
    _remote.getAll(userId).then((data) => _local.save(data));

    return cached;
  }

  @override
  Future<void> markClass({
    required String userId,
    required String subjectId,
    required bool attended,
  }) async {
    try {
      await _remote.markClass(
        userId: userId,
        subjectId: subjectId,
        attended: attended,
      );
      // Recalculate overall attendance and update summary
      final all = await _remote.getAll(userId);
      if (all.isNotEmpty) {
        final totalAll = all.fold(0, (sum, a) => sum + a.totalClasses);
        final attendedAll = all.fold(0, (sum, a) => sum + a.attendedClasses);
        final overallPct = totalAll > 0 ? (attendedAll / totalAll) * 100 : 0.0;
        await _remote.updateSummary(userId, overallPct);
      }
    } catch (e) {
      throw ServerFailure('Failed to mark class: $e');
    }
  }

  @override
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  }) async {
    try {
      await _remote.addSubject(
        userId: userId,
        subject: subject,
        subjectCode: subjectCode,
      );
    } catch (e) {
      throw ServerFailure('Failed to add subject: $e');
    }
  }

  @override
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  }) async {
    try {
      await _remote.deleteSubject(userId: userId, subjectId: subjectId);
    } catch (e) {
      throw ServerFailure('Failed to delete subject: $e');
    }
  }
}
