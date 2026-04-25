import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/attendance_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Live stream of attendance data from Firestore
final attendanceStreamProvider =
    StreamProvider.autoDispose<List<AttendanceModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(attendanceRepoProvider).watchAttendance(userId);
});

/// Overall attendance percentage (0.0 - 1.0)
final overallAttendanceProvider = Provider.autoDispose<double>((ref) {
  final data = ref.watch(attendanceStreamProvider).valueOrNull ?? [];
  if (data.isEmpty) return 0.0;
  final total = data.fold(0, (sum, a) => sum + a.totalClasses);
  final attended = data.fold(0, (sum, a) => sum + a.attendedClasses);
  return total > 0 ? attended / total : 0.0;
});
