import '../../domain/models/assignment_model.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/services/notification_service.dart';
import '../remote/assignments_remote.dart';

class AssignmentRepositoryImpl implements IAssignmentRepository {
  final AssignmentsRemote _remote;
  final NotificationService _notifications = NotificationService();

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
      // Schedule a reminder the evening before the due date.
      _scheduleAssignmentReminder(assignment);
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
      // Cancel reminder when marked completed.
      if (status == 'completed') {
        _notifications.cancelNotification(_assignmentNotifId(assignmentId));
      }
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
      _notifications.cancelNotification(_assignmentNotifId(assignmentId));
      await _remote.deleteAssignment(userId: userId, assignmentId: assignmentId);
    } catch (e) {
      throw ServerFailure('Failed to delete assignment: $e');
    }
  }

  /// Schedule a one-time reminder at 8 PM the day before the due date.
  void _scheduleAssignmentReminder(AssignmentModel assignment) {
    final reminderTime = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day - 1,
      20, 0, // 8:00 PM
    );
    if (reminderTime.isBefore(DateTime.now())) return;
    _notifications.scheduleClassReminder(
      title: 'Assignment due tomorrow',
      body: assignment.title,
      scheduledTime: reminderTime,
      id: _assignmentNotifId(assignment.id),
    );
  }

  /// Stable notification ID from assignment ID string.
  int _assignmentNotifId(String assignmentId) {
    return assignmentId.hashCode.abs().remainder(90000) + 10000;
  }
}
