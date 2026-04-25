import '../models/assignment_model.dart';
import '../repositories/i_assignment_repository.dart';

class GetDueAssignments {
  final IAssignmentRepository _repo;
  GetDueAssignments(this._repo);

  Stream<List<AssignmentModel>> call(String userId) =>
      _repo.watchAssignments(userId);
}
