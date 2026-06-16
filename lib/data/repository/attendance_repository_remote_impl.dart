import '../remote/attendance_remote.dart';
import '../../domain/models/attendance_model.dart';
import '../../domain/repositories/i_attendance_repository.dart';

class AttendanceRepositoryRemoteImpl implements IAttendanceRepository {
  final AttendanceRemote _remote;

  AttendanceRepositoryRemoteImpl(this._remote);

  @override
  Stream<List<AttendanceModel>> watchAttendance(String userId) {
    return _remote.watchAll(userId);
  }

  @override
  Future<List<AttendanceModel>> getOfflineFirst(String userId) async {
    return _remote.getAll(userId);
  }

  @override
  Future<void> markClass({
    required String userId,
    required String subjectId,
    required bool attended,
  }) async {
    await _remote.markClass(userId: userId, subjectId: subjectId, attended: attended);
  }

  @override
  Future<void> markSlot({
    required String userId,
    required String slotId,
    required bool attended,
    DateTime? date,
  }) async {
    // We need to resolve the subjectId from the slotId in a real app, 
    // but for the remote implementation we'll assume the UI passes the subjectId 
    // or we handle it via the markClass logic.
    // In this simple cloud version, slotId is often ignored in favor of subjectId.
  }

  @override
  Future<Map<String, bool>> getSlotMarksForDate({
    required String userId,
    required DateTime date,
  }) async {
    // Cloud version doesn't track individual dates yet for performance
    return {};
  }

  @override
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  }) async {
    await _remote.addSubject(userId: userId, subject: subject, subjectCode: subjectCode);
  }

  @override
  Future<void> updateSubjectSettings({
    required String userId,
    required String subjectId,
    double? targetPercentage,
    int? totalClassesInSemester,
    bool clearSemesterTotal = false,
  }) async {
    await _remote.updateSubjectSettings(
      userId: userId,
      subjectId: subjectId,
      targetPercentage: targetPercentage,
      totalClassesInSemester: totalClassesInSemester,
      clearSemesterTotal: clearSemesterTotal,
    );
  }

  @override
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  }) async {
    await _remote.deleteSubject(userId: userId, subjectId: subjectId);
  }
}
