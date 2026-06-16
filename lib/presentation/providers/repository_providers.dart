import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/remote/attendance_remote.dart';
import '../../data/remote/timetable_remote.dart';
import '../../data/remote/assignments_remote.dart';
import '../../data/remote/notes_remote.dart';
import '../../data/local/academic_local_store.dart';
import '../../data/repository/attendance_repository_remote_impl.dart';
import '../../data/repository/timetable_repository_remote_impl.dart';
import '../../data/repository/assignment_repository_impl.dart';
import '../../data/repository/notes_repository_impl.dart';
import '../../domain/repositories/i_attendance_repository.dart';
import '../../domain/repositories/i_timetable_repository.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import '../../domain/repositories/i_notes_repository.dart';

// ── Singletons ──────────────────────────────────────────────
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ── Local Academic Store ───────────────────────────────────
final academicLocalStoreProvider = Provider<AcademicLocalStore>((ref) {
  return AcademicLocalStore();
});

// ── Remote Sources ──────────────────────────────────────────

final assignmentsRemoteProvider = Provider<AssignmentsRemote>((ref) {
  return AssignmentsRemote(ref.watch(firestoreServiceProvider));
});

final notesRemoteProvider = Provider<NotesRemote>((ref) {
  return NotesRemote(ref.watch(firestoreServiceProvider));
});

final attendanceRemoteProvider = Provider<AttendanceRemote>((ref) {
  return AttendanceRemote(ref.watch(firestoreServiceProvider));
});

final timetableRemoteProvider = Provider<TimetableRemote>((ref) {
  return TimetableRemote(ref.watch(firestoreServiceProvider));
});

// ── Repositories ────────────────────────────────────────────
final attendanceRepoProvider = Provider<IAttendanceRepository>((ref) {
  return AttendanceRepositoryRemoteImpl(
    ref.watch(attendanceRemoteProvider),
  );
});

final timetableRepoProvider = Provider<ITimetableRepository>((ref) {
  return TimetableRepositoryRemoteImpl(
    ref.watch(timetableRemoteProvider),
  );
});

final assignmentRepoProvider = Provider<IAssignmentRepository>((ref) {
  return AssignmentRepositoryImpl(
    ref.watch(assignmentsRemoteProvider),
  );
});

final notesRepoProvider = Provider<INotesRepository>((ref) {
  return NotesRepositoryImpl(
    ref.watch(notesRemoteProvider),
  );
});
