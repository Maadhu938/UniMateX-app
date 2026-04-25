import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/remote/attendance_remote.dart';
import '../../data/remote/timetable_remote.dart';
import '../../data/remote/assignments_remote.dart';
import '../../data/remote/notes_remote.dart';
import '../../data/local/attendance_local.dart';
import '../../data/local/timetable_local.dart';
import '../../data/repository/attendance_repository_impl.dart';
import '../../data/repository/timetable_repository_impl.dart';
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

// ── Remote Sources ──────────────────────────────────────────
final attendanceRemoteProvider = Provider<AttendanceRemote>((ref) {
  return AttendanceRemote(ref.watch(firestoreServiceProvider));
});

final timetableRemoteProvider = Provider<TimetableRemote>((ref) {
  return TimetableRemote(ref.watch(firestoreServiceProvider));
});

final assignmentsRemoteProvider = Provider<AssignmentsRemote>((ref) {
  return AssignmentsRemote(ref.watch(firestoreServiceProvider));
});

final notesRemoteProvider = Provider<NotesRemote>((ref) {
  return NotesRemote(ref.watch(firestoreServiceProvider));
});

// ── Local Caches ────────────────────────────────────────────
final attendanceLocalProvider = Provider<AttendanceLocal>((ref) {
  return AttendanceLocal();
});

final timetableLocalProvider = Provider<TimetableLocal>((ref) {
  return TimetableLocal();
});

// ── Repositories ────────────────────────────────────────────
final attendanceRepoProvider = Provider<IAttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    ref.watch(attendanceRemoteProvider),
    ref.watch(attendanceLocalProvider),
  );
});

final timetableRepoProvider = Provider<ITimetableRepository>((ref) {
  return TimetableRepositoryImpl(
    ref.watch(timetableRemoteProvider),
    ref.watch(timetableLocalProvider),
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
