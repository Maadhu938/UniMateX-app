import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/attendance_record_model.dart';
import '../../domain/models/subject_model.dart';
import '../../domain/models/timetable_slot_model.dart';
import 'hive_service.dart';

class AcademicLocalStore {
  Box<Map> get _subjectsBox => Hive.box<Map>(HiveService.subjectsBox);
  Box<Map> get _slotsBox => Hive.box<Map>(HiveService.timetableSlotsBox);
  Box<Map> get _recordsBox => Hive.box<Map>(HiveService.attendanceRecordsBox);
  Box<Map> get _metaBox => Hive.box<Map>(HiveService.metaBox);
  Box<Map> get _legacyAttendanceBox => Hive.box<Map>(HiveService.attendanceBox);
  Box<Map> get _legacyTimetableBox => Hive.box<Map>(HiveService.timetableBox);

  Future<void> ensureMigrated() async {
    final alreadyMigrated = (_metaBox.get('schema_v2') ?? const {})['done'] == true;
    if (alreadyMigrated) return;

    await _migrateLegacyData();
    await _metaBox.put('schema_v2', {
      'done': true,
      'migratedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SubjectModel>> getSubjects() async {
    return _subjectsBox.values
        .map((raw) => SubjectModel.fromMap(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<List<TimetableSlotModel>> getSlots() async {
    return _slotsBox.values
        .map((raw) => TimetableSlotModel.fromMap(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) {
        final byDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (byDay != 0) return byDay;
        return a.startMinutes.compareTo(b.startMinutes);
      });
  }

  Future<List<AttendanceRecordModel>> getAttendanceRecords() async {
    return _recordsBox.values
        .map((raw) => AttendanceRecordModel.fromMap(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> putSubject(SubjectModel subject) async {
    await _subjectsBox.put(subject.id, subject.toMap());
  }

  Future<void> putSlot(TimetableSlotModel slot) async {
    await _slotsBox.put(slot.id, slot.toMap());
  }

  Future<void> putAttendanceRecord(AttendanceRecordModel record) async {
    await _recordsBox.put(record.id, record.toMap());
  }

  Future<void> deleteSubjectCascade(String subjectId) async {
    await _subjectsBox.delete(subjectId);

    final slots = await getSlots();
    final slotIdsToDelete = slots
        .where((slot) => slot.subjectId == subjectId)
        .map((slot) => slot.id)
        .toSet();

    for (final slotId in slotIdsToDelete) {
      await _slotsBox.delete(slotId);
    }

    final records = await getAttendanceRecords();
    for (final record in records) {
      if (record.subjectId == subjectId || slotIdsToDelete.contains(record.slotId)) {
        await _recordsBox.delete(record.id);
      }
    }
  }

  Future<bool> hasRecordForSlotOnDate({
    required String slotId,
    required DateTime date,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final records = await getAttendanceRecords();
    return records.any((record) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      return record.slotId == slotId && recordDate == normalized;
    });
  }

  Future<SubjectModel?> findSubjectByCodeOrName({
    required String code,
    required String name,
  }) async {
    final subjects = await getSubjects();
    final normalizedCode = code.trim().toLowerCase();
    final normalizedName = name.trim().toLowerCase();

    for (final subject in subjects) {
      if (normalizedCode.isNotEmpty && subject.code.trim().toLowerCase() == normalizedCode) {
        return subject;
      }
      if (subject.name.trim().toLowerCase() == normalizedName) {
        return subject;
      }
    }

    return null;
  }

  SubjectModel createSubject({
    required String name,
    required String code,
    String teacher = '',
    double targetPercentage = 0.75,
    int? totalClassesInSemester,
  }) {
    final now = DateTime.now();
    return SubjectModel(
      id: _newId('subj'),
      name: name,
      code: code,
      teacher: teacher,
      targetPercentage: targetPercentage,
      totalClassesInSemester: totalClassesInSemester,
      createdAt: now,
      updatedAt: now,
    );
  }

  TimetableSlotModel createSlot({
    required String subjectId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
    required String room,
  }) {
    final now = DateTime.now();
    return TimetableSlotModel(
      id: _newId('slot'),
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      room: room,
      createdAt: now,
      updatedAt: now,
    );
  }

  AttendanceRecordModel createRecord({
    required String slotId,
    required String subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) {
    final now = DateTime.now();
    return AttendanceRecordModel(
      id: _newId('rec'),
      slotId: slotId,
      subjectId: subjectId,
      date: DateTime(date.year, date.month, date.day),
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _migrateLegacyData() async {
    final subjectByLegacyKey = <String, SubjectModel>{};
    final manualSlotIdBySubjectId = <String, String>{};

    final legacyTimetable = _legacyTimetableBox.values
        .map((raw) => Map<String, dynamic>.from(raw))
        .toList();

    final legacyAttendance = _legacyAttendanceBox.values
        .map((raw) => Map<String, dynamic>.from(raw))
        .toList();

    Future<SubjectModel> ensureSubject({
      required String name,
      required String code,
    }) async {
      final key = '${code.trim().toLowerCase()}|${name.trim().toLowerCase()}';
      final existingInMemory = subjectByLegacyKey[key];
      if (existingInMemory != null) return existingInMemory;

      final existingStored = await findSubjectByCodeOrName(code: code, name: name);
      if (existingStored != null) {
        subjectByLegacyKey[key] = existingStored;
        return existingStored;
      }

      final created = createSubject(name: name, code: code, targetPercentage: 0.75);
      await putSubject(created);
      subjectByLegacyKey[key] = created;
      return created;
    }

    for (final item in legacyTimetable) {
      final subjectName = (item['subject'] ?? '').toString();
      final subjectCode = (item['subjectCode'] ?? '').toString();
      if (subjectName.trim().isEmpty && subjectCode.trim().isEmpty) {
        continue;
      }

      final subject = await ensureSubject(name: subjectName, code: subjectCode);
      final slot = TimetableSlotModel(
        id: item['id']?.toString().isNotEmpty == true ? 'slot_legacy_${item['id']}' : _newId('slot'),
        subjectId: subject.id,
        dayOfWeek: item['dayOfWeek'] ?? 1,
        startMinutes: item['startMinutes'] ?? 0,
        endMinutes: item['endMinutes'] ?? 0,
        room: (item['room'] ?? '').toString(),
        createdAt: DateTime.tryParse((item['createdAt'] ?? '').toString()) ?? DateTime.now(),
        updatedAt: DateTime.tryParse((item['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      );
      await putSlot(slot);
    }

    for (final item in legacyAttendance) {
      final subjectName = (item['subject'] ?? '').toString();
      final subjectCode = (item['subjectCode'] ?? '').toString();
      if (subjectName.trim().isEmpty && subjectCode.trim().isEmpty) {
        continue;
      }

      final subject = await ensureSubject(name: subjectName, code: subjectCode);
      final total = item['totalClasses'] is int ? item['totalClasses'] as int : 0;
      final attended = item['attendedClasses'] is int ? item['attendedClasses'] as int : 0;

      final slotId = manualSlotIdBySubjectId.putIfAbsent(subject.id, () => 'slot_manual_${subject.id}');
      if (_slotsBox.get(slotId) == null) {
        final syntheticSlot = TimetableSlotModel(
          id: slotId,
          subjectId: subject.id,
          dayOfWeek: 1,
          startMinutes: 0,
          endMinutes: 1,
          room: 'Migrated',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await putSlot(syntheticSlot);
      }

      for (var i = 0; i < total; i++) {
        final status = i < attended ? AttendanceStatus.present : AttendanceStatus.absent;
        final date = DateTime.now().subtract(Duration(days: total - i));
        final recordId = 'rec_mig_${subject.id}_$i';

        if (_recordsBox.get(recordId) != null) continue;

        final record = AttendanceRecordModel(
          id: recordId,
          slotId: slotId,
          subjectId: subject.id,
          date: DateTime(date.year, date.month, date.day),
          status: status,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await putAttendanceRecord(record);
      }
    }
  }

  String _newId(String prefix) {
    final random = Random().nextInt(1 << 32).toRadixString(16);
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$random';
  }
}
