import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/timetable_model.dart';
import '../../domain/models/subject_model.dart';
import '../../domain/repositories/i_timetable_repository.dart';
import '../../domain/models/timetable_slot_model.dart';
import '../local/academic_local_store.dart';
import '../local/hive_service.dart';

class TimetableRepositoryImpl implements ITimetableRepository {
  final AcademicLocalStore _store;

  TimetableRepositoryImpl(this._store);

  @override
  Stream<List<TimetableModel>> watchTimetable(String userId) {
    return Stream.multi((controller) async {
      await _store.ensureMigrated();

      Future<void> emitSnapshot() async {
        controller.add(await _buildTimetableSnapshot());
      }

      await emitSnapshot();

      final slotsSub =
          Hive.box<Map>(HiveService.timetableSlotsBox).watch().listen((_) {
        emitSnapshot();
      });
      final subjectsSub =
          Hive.box<Map>(HiveService.subjectsBox).watch().listen((_) {
        emitSnapshot();
      });

      controller.onCancel = () {
        slotsSub.cancel();
        subjectsSub.cancel();
      };
    });
  }

  @override
  Future<List<TimetableModel>> getOfflineFirst(String userId) async {
    await _store.ensureMigrated();
    return _buildTimetableSnapshot();
  }

  @override
  Future<List<TimetableModel>> getByDay(String userId, int dayOfWeek) async {
    await _store.ensureMigrated();
    final all = await _buildTimetableSnapshot();
    return all.where((t) => t.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  @override
  Future<void> addSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    await _store.ensureMigrated();

    final subject = await _resolveOrCreateSubject(
      name: slot.subject,
      code: slot.subjectCode,
    );

    final created = _store.createSlot(
      subjectId: subject.id,
      dayOfWeek: slot.dayOfWeek,
      startMinutes: slot.startMinutes,
      endMinutes: slot.endMinutes,
      room: slot.room,
    );
    await _store.putSlot(created);
  }

  @override
  Future<void> updateSlot({
    required String userId,
    required TimetableModel slot,
  }) async {
    await _store.ensureMigrated();

    final subject = await _resolveOrCreateSubject(
      name: slot.subject,
      code: slot.subjectCode,
    );

    final existingSlots = await _store.getSlots();
    TimetableSlotModel? existing;
    for (final item in existingSlots) {
      if (item.id == slot.id) {
        existing = item;
        break;
      }
    }

    if (existing == null) {
      final created = TimetableSlotModel(
        id: slot.id.isNotEmpty ? slot.id : 'slot_${DateTime.now().microsecondsSinceEpoch}',
        subjectId: subject.id,
        dayOfWeek: slot.dayOfWeek,
        startMinutes: slot.startMinutes,
        endMinutes: slot.endMinutes,
        room: slot.room,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _store.putSlot(created);
      return;
    }

    final updated = existing.copyWith(
      subjectId: subject.id,
      dayOfWeek: slot.dayOfWeek,
      startMinutes: slot.startMinutes,
      endMinutes: slot.endMinutes,
      room: slot.room,
    );
    await _store.putSlot(updated);
  }

  @override
  Future<void> deleteSlot({
    required String userId,
    required String slotId,
  }) async {
    await _store.ensureMigrated();
    await Hive.box<Map>(HiveService.timetableSlotsBox).delete(slotId);
  }

  Future<List<TimetableModel>> _buildTimetableSnapshot() async {
    final slots = await _store.getSlots();
    final subjects = await _store.getSubjects();
    final subjectById = {for (final subject in subjects) subject.id: subject};

    return slots.map((slot) {
      final subject = subjectById[slot.subjectId];
      return TimetableModel(
        id: slot.id,
        subject: subject?.name ?? 'Unknown Subject',
        subjectCode: subject?.code ?? '',
        dayOfWeek: slot.dayOfWeek,
        startMinutes: slot.startMinutes,
        endMinutes: slot.endMinutes,
        room: slot.room,
        createdAt: slot.createdAt,
        updatedAt: slot.updatedAt,
      );
    }).toList()
      ..sort((a, b) {
        final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (byDay != 0) return byDay;
        return a.startMinutes.compareTo(b.startMinutes);
      });
  }

  Future<SubjectModel> _resolveOrCreateSubject({
    required String name,
    required String code,
  }) async {
    final existing = await _store.findSubjectByCodeOrName(code: code, name: name);
    if (existing != null) return existing;

    final created = _store.createSubject(
      name: name,
      code: code,
      targetPercentage: 0.75,
    );
    await _store.putSubject(created);
    return created;
  }
}
