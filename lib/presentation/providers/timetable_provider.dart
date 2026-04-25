import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/timetable_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Live stream of all timetable slots
final timetableStreamProvider =
    StreamProvider.autoDispose<List<TimetableModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(timetableRepoProvider).watchTimetable(userId);
});

/// Today's classes only
final todayClassesProvider =
    Provider.autoDispose<List<TimetableModel>>((ref) {
  final all = ref.watch(timetableStreamProvider).valueOrNull ?? [];
  final today = DateTime.now().weekday;
  return all.where((t) => t.dayOfWeek == today).toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
});

/// Classes filtered by day of week
final classesByDayProvider =
    Provider.autoDispose.family<List<TimetableModel>, int>((ref, day) {
  final all = ref.watch(timetableStreamProvider).valueOrNull ?? [];
  return all.where((t) => t.dayOfWeek == day).toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
});
