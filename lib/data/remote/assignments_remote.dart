import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/assignment_model.dart';
import 'firestore_service.dart';

class AssignmentsRemote {
  final FirestoreService _firestore;
  AssignmentsRemote(this._firestore);

  Stream<List<AssignmentModel>> watchAll(String userId) {
    return _firestore
        .userCollection(userId, 'assignments')
        .orderBy('dueDate')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AssignmentModel.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<List<AssignmentModel>> getByStatus(
      String userId, String status) async {
    final snap = await _firestore
        .userCollection(userId, 'assignments')
        .where('status', isEqualTo: status)
        .orderBy('dueDate')
        .get();
    return snap.docs
        .map((doc) => AssignmentModel.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<void> addAssignment({
    required String userId,
    required AssignmentModel assignment,
  }) async {
    final data = assignment.toDoc();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.userCollection(userId, 'assignments').add(data);
  }

  Future<void> updateStatus({
    required String userId,
    required String assignmentId,
    required String status,
  }) async {
    await _firestore.userDoc(userId, 'assignments', assignmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAssignment({
    required String userId,
    required AssignmentModel assignment,
  }) async {
    final data = assignment.toDoc();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.userDoc(userId, 'assignments', assignment.id).update(data);
  }

  Future<void> deleteAssignment({
    required String userId,
    required String assignmentId,
  }) async {
    await _firestore.userDoc(userId, 'assignments', assignmentId).delete();
  }

  /// Update pending count in summary doc
  Future<void> updateSummaryCount(String userId, int pendingCount) async {
    await _firestore.instance.doc('users/$userId/stats/summary').set({
      'pendingAssignments': pendingCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
