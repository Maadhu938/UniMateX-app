import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/note_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Live stream of all notes
final notesStreamProvider =
    StreamProvider.autoDispose<List<NoteModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(notesRepoProvider).watchNotes(userId);
});
