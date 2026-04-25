import '../models/attendance_model.dart';
import '../repositories/i_attendance_repository.dart';

class GetAttendance {
  final IAttendanceRepository _repo;
  GetAttendance(this._repo);

  Stream<List<AttendanceModel>> call(String userId) =>
      _repo.watchAttendance(userId);
}
