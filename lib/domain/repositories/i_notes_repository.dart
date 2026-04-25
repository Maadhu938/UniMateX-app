import '../models/note_model.dart';

abstract class INotesRepository {
  Stream<List<NoteModel>> watchNotes(String userId);

  Future<String> saveNote({
    required String userId,
    required NoteModel note,
  });

  Future<void> deleteNote({
    required String userId,
    required String noteId,
  });
}
