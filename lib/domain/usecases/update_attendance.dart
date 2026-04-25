import '../repositories/i_attendance_repository.dart';

class UpdateAttendance {
  final IAttendanceRepository _repo;
  UpdateAttendance(this._repo);

  Future<void> call({
    required String userId,
    required String subjectId,
    required bool attended,
  }) =>
      _repo.markClass(
        userId: userId,
        subjectId: subjectId,
        attended: attended,
      );
}
