import '../models/assignment_model.dart';

abstract class IAssignmentRepository {
  Stream<List<AssignmentModel>> watchAssignments(String userId);
  Future<List<AssignmentModel>> getByStatus(String userId, String status);

  Future<void> addAssignment({
    required String userId,
    required AssignmentModel assignment,
  });

  Future<void> updateStatus({
    required String userId,
    required String assignmentId,
    required String status,
  });

  Future<void> updateAssignment({
    required String userId,
    required AssignmentModel assignment,
  });

  Future<void> deleteAssignment({
    required String userId,
    required String assignmentId,
  });
}
