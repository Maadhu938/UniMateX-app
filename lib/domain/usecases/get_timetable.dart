import '../models/timetable_model.dart';
import '../repositories/i_timetable_repository.dart';

class GetTimetable {
  final ITimetableRepository _repo;
  GetTimetable(this._repo);

  Stream<List<TimetableModel>> call(String userId) =>
      _repo.watchTimetable(userId);
}
