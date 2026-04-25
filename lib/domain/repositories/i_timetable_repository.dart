import '../models/timetable_model.dart';

abstract class ITimetableRepository {
  Stream<List<TimetableModel>> watchTimetable(String userId);
  Future<List<TimetableModel>> getOfflineFirst(String userId);
  Future<List<TimetableModel>> getByDay(String userId, int dayOfWeek);

  Future<void> addSlot({
    required String userId,
    required TimetableModel slot,
  });

  Future<void> updateSlot({
    required String userId,
    required TimetableModel slot,
  });

  Future<void> deleteSlot({
    required String userId,
    required String slotId,
  });
}
