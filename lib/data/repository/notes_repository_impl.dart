import '../../domain/models/note_model.dart';
import '../../domain/repositories/i_notes_repository.dart';
import '../../core/errors/failures.dart';
import '../remote/notes_remote.dart';

class NotesRepositoryImpl implements INotesRepository {
  final NotesRemote _remote;

  NotesRepositoryImpl(this._remote);

  @override
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _remote.watchAll(userId);
  }

  @override
  Future<String> saveNote({
    required String userId,
    required NoteModel note,
  }) async {
    try {
      return await _remote.saveNote(userId: userId, note: note);
    } catch (e) {
      throw ServerFailure('Failed to save note: $e');
    }
  }

  @override
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      await _remote.deleteNote(userId: userId, noteId: noteId);
    } catch (e) {
      throw ServerFailure('Failed to delete note: $e');
    }
  }
}
