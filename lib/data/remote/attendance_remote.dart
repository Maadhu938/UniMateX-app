import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/attendance_model.dart';
import 'firestore_service.dart';

class AttendanceRemote {
  final FirestoreService _firestore;
  AttendanceRemote(this._firestore);

  /// Live stream of all attendance docs for a user
  Stream<List<AttendanceModel>> watchAll(String userId) {
    return _firestore
        .userCollection(userId, 'attendance')
        .orderBy('subject')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AttendanceModel.fromDoc(doc.id, doc.data()))
            .toList());
  }

  /// One-time fetch
  Future<List<AttendanceModel>> getAll(String userId) async {
    final snap = await _firestore
        .userCollection(userId, 'attendance')
        .orderBy('subject')
        .get();
    return snap.docs
        .map((doc) => AttendanceModel.fromDoc(doc.id, doc.data()))
        .toList();
  }

  /// Mark a class — increment totalClasses and optionally attendedClasses
  Future<void> markClass({
    required String userId,
    required String subjectId,
    required bool attended,
  }) async {
    final ref = _firestore.userDoc(userId, 'attendance', subjectId);
    await ref.update({
      'totalClasses': FieldValue.increment(1),
      if (attended) 'attendedClasses': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMarkedDate': FieldValue.serverTimestamp(),
    });
  }

  /// Add a new subject
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  }) async {
    await _firestore.userCollection(userId, 'attendance').add({
      'subject': subject,
      'subjectCode': subjectCode,
      'totalClasses': 0,
      'attendedClasses': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a subject
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  }) async {
    await _firestore.userDoc(userId, 'attendance', subjectId).delete();
  }

  /// Update the dashboard summary doc
  Future<void> updateSummary(String userId, double overallPct) async {
    await _firestore.instance.doc('users/$userId/stats/summary').set({
      'overallAttendance': overallPct.round(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
