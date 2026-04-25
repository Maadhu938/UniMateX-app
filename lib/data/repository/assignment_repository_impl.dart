import '../../domain/models/assignment_model.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import '../../core/errors/failures.dart';
import '../remote/assignments_remote.dart';

class AssignmentRepositoryImpl implements IAssignmentRepository {
  final AssignmentsRemote _remote;

  AssignmentRepositoryImpl(this._remote);

  @override
  Stream<List<AssignmentModel>> watchAssignments(String userId) {
    return _remote.watchAll(userId);
  }

  @override
  Future<List<AssignmentModel>> getByStatus(
      String userId, String status) async {
    try {
      return await _remote.getByStatus(userId, status);
    } catch (e) {
      throw ServerFailure('Failed to get assignments: $e');
    }
  }

  @override
  Future<void> addAssignment({
    required String userId,
    required AssignmentModel assignment,
  }) async {
    try {
      await _remote.addAssignment(userId: userId, assignment: assignment);
    } catch (e) {
      throw ServerFailure('Failed to add assignment: $e');
    }
  }

  @override
  Future<void> updateStatus({
    required String userId,
    required String assignmentId,
    required String status,
  }) async {
    try {
      await _remote.updateStatus(
        userId: userId,
        assignmentId: assignmentId,
        status: status,
      );
    } catch (e) {
      throw ServerFailure('Failed to update assignment: $e');
    }
  }

  @override
  Future<void> updateAssignment({
    required String userId,
    required AssignmentModel assignment,
  }) async {
    try {
      await _remote.updateAssignment(userId: userId, assignment: assignment);
    } catch (e) {
      throw ServerFailure('Failed to update assignment: $e');
    }
  }

  @override
  Future<void> deleteAssignment({
    required String userId,
    required String assignmentId,
  }) async {
    try {
      await _remote.deleteAssignment(userId: userId, assignmentId: assignmentId);
    } catch (e) {
      throw ServerFailure('Failed to delete assignment: $e');
    }
  }
}
