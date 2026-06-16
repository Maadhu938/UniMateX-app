import '../remote/timetable_remote.dart';
import '../../domain/models/timetable_model.dart';
import '../../domain/repositories/i_timetable_repository.dart';
import '../../core/services/notification_service.dart';

class TimetableRepositoryRemoteImpl implements ITimetableRepository {
  final TimetableRemote _remote;
  final NotificationService _notifications = NotificationService();

  TimetableRepositoryRemoteImpl(this._remote);

  @override
  Stream<List<TimetableModel>> watchTimetable(String userId) {
    return _remote.watchAll(userId);
  }

  @override
  Future<List<TimetableModel>> getOfflineFirst(String userId) async {
    return _remote.getAll(userId);
  }

  @override
  Future<List<TimetableModel>> getByDay(String userId, int dayOfWeek) async {
    return _remote.getByDay(userId, dayOfWeek);
  }

  @override
  Future<void> addSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    await _remote.addSlot(userId: userId, slot: slot);
    
    // Schedule notification
    await _notifications.scheduleWeeklyClassReminder(
      className: slot.subject,
      room: slot.room,
      dayOfWeek: slot.dayOfWeek,
      startMinutes: slot.startMinutes,
    );
  }

  @override
  Future<void> updateSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    await _remote.updateSlot(userId: userId, slot: slot);
    
    // Re-schedule notification
    await _notifications.scheduleWeeklyClassReminder(
      className: slot.subject,
      room: slot.room,
      dayOfWeek: slot.dayOfWeek,
      startMinutes: slot.startMinutes,
    );
  }

  @override
  Future<void> deleteSlot({
    required String userId,
    required String slotId,
  }) async {
    await _remote.deleteSlot(userId: userId, slotId: slotId);
  }
}
