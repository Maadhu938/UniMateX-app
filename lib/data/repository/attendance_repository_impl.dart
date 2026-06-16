import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/attendance_model.dart';
import '../../domain/models/attendance_record_model.dart';
import '../../domain/models/timetable_slot_model.dart';
import '../../domain/repositories/i_attendance_repository.dart';
import '../local/academic_local_store.dart';
import '../local/hive_service.dart';

class AttendanceRepositoryImpl implements IAttendanceRepository {
  final AcademicLocalStore _store;

  AttendanceRepositoryImpl(this._store);

  @override
  Stream<List<AttendanceModel>> watchAttendance(String userId) {
    return Stream.multi((controller) async {
      await _store.ensureMigrated();

      Future<void> emitSnapshot() async {
        controller.add(await _buildAttendanceSnapshot());
      }

      await emitSnapshot();

      final recordsSub =
          Hive.box<Map>(HiveService.attendanceRecordsBox).watch().listen((_) {
        emitSnapshot();
      });

      final subjectsSub =
          Hive.box<Map>(HiveService.subjectsBox).watch().listen((_) {
        emitSnapshot();
      });

      controller.onCancel = () {
        recordsSub.cancel();
        subjectsSub.cancel();
      };
    });
  }

  @override
  Future<List<AttendanceModel>> getOfflineFirst(String userId) async {
    await _store.ensureMigrated();
    return _buildAttendanceSnapshot();
  }

  @override
  Future<void> markClass({
    required String userId,
    required String subjectId,
    required bool attended,
  }) async {
    await _store.ensureMigrated();

    final today = DateTime.now();
    final manualSlotId = 'slot_manual_$subjectId';

    final slots = await _store.getSlots();
    final manualSlotExists = slots.any((slot) => slot.id == manualSlotId);
    if (!manualSlotExists) {
      final manualSlot = TimetableSlotModel(
        id: manualSlotId,
        subjectId: subjectId,
        dayOfWeek: today.weekday,
        startMinutes: 0,
        endMinutes: 1,
        room: 'Manual',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _store.putSlot(manualSlot);
    }

    final alreadyMarked = await _store.hasRecordForSlotOnDate(
      slotId: manualSlotId,
      date: today,
    );
    if (alreadyMarked) return;

    final record = _store.createRecord(
      slotId: manualSlotId,
      subjectId: subjectId,
      date: today,
      status: attended ? AttendanceStatus.present : AttendanceStatus.absent,
    );
    await _store.putAttendanceRecord(record);
  }

  @override
  Future<void> markSlot({
    required String userId,
    required String slotId,
    required bool attended,
    DateTime? date,
  }) async {
    await _store.ensureMigrated();

    final slots = await _store.getSlots();
    TimetableSlotModel? slot;
    for (final item in slots) {
      if (item.id == slotId) {
        slot = item;
        break;
      }
    }
    if (slot == null) return;

    final markDate = date ?? DateTime.now();
    final alreadyMarked = await _store.hasRecordForSlotOnDate(
      slotId: slotId,
      date: markDate,
    );
    if (alreadyMarked) return;

    final record = _store.createRecord(
      slotId: slotId,
      subjectId: slot.subjectId,
      date: markDate,
      status: attended ? AttendanceStatus.present : AttendanceStatus.absent,
    );
    await _store.putAttendanceRecord(record);
  }

  @override
  Future<Map<String, bool>> getSlotMarksForDate({
    required String userId,
    required DateTime date,
  }) async {
    await _store.ensureMigrated();

    final normalized = DateTime(date.year, date.month, date.day);
    final records = await _store.getAttendanceRecords();

    final result = <String, bool>{};
    for (final record in records) {
      if (record.status == AttendanceStatus.cancelled) continue;
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      if (recordDate != normalized) continue;

      result[record.slotId] = record.status == AttendanceStatus.present;
    }

    return result;
  }

  @override
  Future<void> addSubject({
    required String userId,
    required String subject,
    required String subjectCode,
  }) async {
    await _store.ensureMigrated();

    final existing = await _store.findSubjectByCodeOrName(
      code: subjectCode,
      name: subject,
    );
    if (existing != null) return;

    final created = _store.createSubject(
      name: subject,
      code: subjectCode,
      targetPercentage: 0.75,
    );
    await _store.putSubject(created);
  }

  @override
  Future<void> updateSubjectSettings({
    required String userId,
    required String subjectId,
    double? targetPercentage,
    int? totalClassesInSemester,
    bool clearSemesterTotal = false,
  }) async {
    await _store.ensureMigrated();
    final subjects = await _store.getSubjects();

    for (final subject in subjects) {
      if (subject.id != subjectId) continue;

      final updated = subject.copyWith(
        targetPercentage: targetPercentage,
        totalClassesInSemester: totalClassesInSemester,
        clearSemesterTotal: clearSemesterTotal,
      );
      await _store.putSubject(updated);
      break;
    }
  }

  @override
  Future<void> deleteSubject({
    required String userId,
    required String subjectId,
  }) async {
    await _store.ensureMigrated();
    await _store.deleteSubjectCascade(subjectId);
  }

  Future<List<AttendanceModel>> _buildAttendanceSnapshot() async {
    final subjects = await _store.getSubjects();
    final records = await _store.getAttendanceRecords();

    final totalBySubject = <String, int>{};
    final presentBySubject = <String, int>{};
    final lastMarkedBySubject = <String, DateTime>{};

    for (final record in records) {
      if (record.status == AttendanceStatus.cancelled) continue;

      totalBySubject[record.subjectId] = (totalBySubject[record.subjectId] ?? 0) + 1;
      if (record.status == AttendanceStatus.present) {
        presentBySubject[record.subjectId] = (presentBySubject[record.subjectId] ?? 0) + 1;
      }

      final current = lastMarkedBySubject[record.subjectId];
      if (current == null || record.date.isAfter(current)) {
        lastMarkedBySubject[record.subjectId] = record.date;
      }
    }

    return subjects.map((subject) {
      final total = totalBySubject[subject.id] ?? 0;
      final attended = presentBySubject[subject.id] ?? 0;
      return AttendanceModel(
        id: subject.id,
        subject: subject.name,
        subjectCode: subject.code,
        totalClasses: total,
        attendedClasses: attended,
        targetPercentage: subject.targetPercentage,
        totalClassesInSemester: subject.totalClassesInSemester,
        createdAt: subject.createdAt,
        updatedAt: subject.updatedAt,
        lastMarkedDate: lastMarkedBySubject[subject.id],
      );
    }).toList()
      ..sort((a, b) => a.subject.toLowerCase().compareTo(b.subject.toLowerCase()));
  }
}
