import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../domain/models/timetable_model.dart';
import '../../domain/models/assignment_model.dart';
import '../../domain/models/attendance_model.dart';
import '../../domain/models/note_model.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';

class QuickAddDialogs {
  static void showAddClassDialog(BuildContext context, WidgetRef ref, {int? initialDay}) {
    final subjectController = TextEditingController();
    final codeController = TextEditingController();
    final roomController = TextEditingController();
    int day = initialDay ?? (DateTime.now().weekday <= 6 ? DateTime.now().weekday : 1);
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    final days = [
      {'id': 1, 'full': 'Monday'},
      {'id': 2, 'full': 'Tuesday'},
      {'id': 3, 'full': 'Wednesday'},
      {'id': 4, 'full': 'Thursday'},
      {'id': 5, 'full': 'Friday'},
      {'id': 6, 'full': 'Saturday'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Add Class', style: TextStyle(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subjectController, decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: codeController, decoration: InputDecoration(labelText: 'Subject Code', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: roomController, decoration: InputDecoration(labelText: 'Room', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: day,
                  decoration: InputDecoration(labelText: 'Day', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: days.map((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['full'] as String))).toList(),
                  onChanged: (v) => setDialogState(() => day = v ?? day),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: startTime);
                          if (t != null) setDialogState(() => startTime = t);
                        },
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Start:\n${startTime.format(ctx)}', textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: endTime);
                          if (t != null) setDialogState(() => endTime = t);
                        },
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('End:\n${endTime.format(ctx)}', textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.trim().isNotEmpty) {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    final slot = TimetableModel(
                      id: '', subject: subjectController.text.trim(), subjectCode: codeController.text.trim(),
                      dayOfWeek: day, startMinutes: startTime.hour * 60 + startTime.minute, endMinutes: endTime.hour * 60 + endTime.minute,
                      room: roomController.text.trim(), createdAt: DateTime.now(), updatedAt: DateTime.now(),
                    );
                    ref.read(timetableRepoProvider).addSlot(userId: userId, slot: slot);
                  }
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddTaskDialog(BuildContext context, WidgetRef ref, {AssignmentModel? initialTask}) {
    final titleC = TextEditingController(text: initialTask?.title);
    final descC = TextEditingController(text: initialTask?.description);
    final subjC = TextEditingController(text: initialTask?.subject);
    DateTime due = initialTask?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(initialTask == null ? 'Add Assignment' : 'Edit Assignment', style: const TextStyle(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleC, decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(controller: descC, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: subjC, decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, initialDate: due, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) ss(() => due = d);
                },
                icon: const Icon(LucideIcons.calendar),
                label: Text('Due: ${DateFormat('MMM d').format(due)}'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.trim().isNotEmpty) {
                  final uid = ref.read(currentUserIdProvider);
                  if (uid != null) {
                    final task = AssignmentModel(
                      id: initialTask?.id ?? '',
                      title: titleC.text.trim(),
                      description: descC.text.trim(),
                      subject: subjC.text.trim(),
                      subjectCode: initialTask?.subjectCode ?? '',
                      dueDate: due,
                      status: initialTask?.status ?? 'pending',
                      createdAt: initialTask?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    if (initialTask == null) {
                      ref.read(assignmentRepoProvider).addAssignment(userId: uid, assignment: task);
                    } else {
                      ref.read(assignmentRepoProvider).updateAssignment(userId: uid, assignment: task);
                    }
                  }
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(initialTask == null ? 'Add Task' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final subjectController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Subject', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g. DBMS',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Subject Code',
                hintText: 'e.g. CS301',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.trim().isNotEmpty) {
                final userId = ref.read(currentUserIdProvider);
                if (userId != null) {
                  ref.read(attendanceRepoProvider).addSubject(
                        userId: userId,
                        subject: subjectController.text.trim(),
                        subjectCode: codeController.text.trim(),
                      );
                }
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  static void showAddNoteEditor(BuildContext context) {
    context.push('/note-editor');
  }
}
