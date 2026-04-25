import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/note_model.dart';
import 'firestore_service.dart';

class NotesRemote {
  final FirestoreService _firestore;
  NotesRemote(this._firestore);

  Stream<List<NoteModel>> watchAll(String userId) {
    return _firestore
        .userCollection(userId, 'notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NoteModel.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<String> saveNote({
    required String userId,
    required NoteModel note,
  }) async {
    final data = note.toDoc();
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (note.id.isEmpty) {
      // New note
      data['createdAt'] = FieldValue.serverTimestamp();
      final ref = await _firestore.userCollection(userId, 'notes').add(data);
      return ref.id;
    } else {
      // Update existing
      await _firestore.userDoc(userId, 'notes', note.id).update(data);
      return note.id;
    }
  }

  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    await _firestore.userDoc(userId, 'notes', noteId).delete();
  }
}
