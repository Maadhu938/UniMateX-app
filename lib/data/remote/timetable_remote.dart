import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/timetable_model.dart';
import 'firestore_service.dart';

class TimetableRemote {
  final FirestoreService _firestore;
  TimetableRemote(this._firestore);

  Stream<List<TimetableModel>> watchAll(String userId) {
    return _firestore
        .userCollection(userId, 'timetable')
        .orderBy('dayOfWeek')
        .orderBy('startMinutes')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TimetableModel.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<List<TimetableModel>> getAll(String userId) async {
    final snap = await _firestore
        .userCollection(userId, 'timetable')
        .orderBy('dayOfWeek')
        .orderBy('startMinutes')
        .get();
    return snap.docs
        .map((doc) => TimetableModel.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<List<TimetableModel>> getByDay(String userId, int day) async {
    final snap = await _firestore
        .userCollection(userId, 'timetable')
        .where('dayOfWeek', isEqualTo: day)
        .orderBy('startMinutes')
        .get();
    return snap.docs
        .map((doc) => TimetableModel.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<void> addSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    final data = slot.toDoc();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.userCollection(userId, 'timetable').add(data);
  }

  Future<void> updateSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    final data = slot.toDoc();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.userDoc(userId, 'timetable', slot.id).update(data);
  }

  Future<void> deleteSlot({
    required String userId,
    required String slotId,
  }) async {
    await _firestore.userDoc(userId, 'timetable', slotId).delete();
  }
}
