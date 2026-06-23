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

    // Schedule recurring weekly notification (15 min before class)
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
    // Cancel the notification for this slot before deleting.
    // The notification ID is derived from dayOfWeek * 10000 + startMinutes,
    // but we don't have the slot data here. Fetch it first.
    try {
      final slots = await _remote.getAll(userId);
      final slot = slots.where((s) => s.id == slotId).firstOrNull;
      if (slot != null) {
        final notifId = slot.dayOfWeek * 10000 + slot.startMinutes;
        await _notifications.cancelNotification(notifId);
      }
    } catch (_) {}
    await _remote.deleteSlot(userId: userId, slotId: slotId);
  }
}
