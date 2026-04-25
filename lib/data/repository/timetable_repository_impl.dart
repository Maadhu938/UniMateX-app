import '../../domain/models/timetable_model.dart';
import '../../domain/repositories/i_timetable_repository.dart';
import '../../core/errors/failures.dart';
import '../remote/timetable_remote.dart';
import '../local/timetable_local.dart';

class TimetableRepositoryImpl implements ITimetableRepository {
  final TimetableRemote _remote;
  final TimetableLocal _local;

  TimetableRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<TimetableModel>> watchTimetable(String userId) {
    return _remote.watchAll(userId).map((data) {
      _local.save(data);
      return data;
    });
  }

  @override
  Future<List<TimetableModel>> getOfflineFirst(String userId) async {
    final cached = await _local.get();
    _remote.getAll(userId).then((data) => _local.save(data));
    return cached;
  }

  @override
  Future<List<TimetableModel>> getByDay(String userId, int dayOfWeek) async {
    try {
      return await _remote.getByDay(userId, dayOfWeek);
    } catch (e) {
      // Fallback to local cache filtered by day
      final all = await _local.get();
      return all.where((t) => t.dayOfWeek == dayOfWeek).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    }
  }

  @override
  Future<void> addSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    try {
      await _remote.addSlot(userId: userId, slot: slot);
    } catch (e) {
      throw ServerFailure('Failed to add timetable slot: $e');
    }
  }

  @override
  Future<void> updateSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    try {
      await _remote.updateSlot(userId: userId, slot: slot);
    } catch (e) {
      throw ServerFailure('Failed to update slot: $e');
    }
  }

  @override
  Future<void> deleteSlot({
    required String userId,
    required String slotId,
  }) async {
    try {
      await _remote.deleteSlot(userId: userId, slotId: slotId);
    } catch (e) {
      throw ServerFailure('Failed to delete slot: $e');
    }
  }
}
