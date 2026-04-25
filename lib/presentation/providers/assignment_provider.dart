import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/assignment_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Live stream of all assignments
final assignmentStreamProvider =
    StreamProvider.autoDispose<List<AssignmentModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(assignmentRepoProvider).watchAssignments(userId);
});

/// Pending assignments count
final pendingAssignmentsCountProvider = Provider.autoDispose<int>((ref) {
  final all = ref.watch(assignmentStreamProvider).valueOrNull ?? [];
  return all.where((a) => a.isPending).length;
});

/// Assignments filtered by status
final assignmentsByStatusProvider =
    Provider.autoDispose.family<List<AssignmentModel>, String>((ref, status) {
  final all = ref.watch(assignmentStreamProvider).valueOrNull ?? [];
  if (status == 'all') return all;
  return all.where((a) => a.status == status).toList();
});
