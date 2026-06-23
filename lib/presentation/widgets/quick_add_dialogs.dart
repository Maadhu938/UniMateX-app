import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../domain/models/timetable_model.dart';
import '../../domain/models/assignment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/settings_provider.dart';

class QuickAddDialogs {
  static void _showSwipeTipIfNeeded(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsServiceProvider);
    if (!settings.swipeTipSeen) {
      // Small delay to let the dialog close and UI settle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.lightbulb, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Tip: You can swipe left on items to delete them.")),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          ),
        );
      });
      await settings.setSwipeTipSeen(true);
    }
  }

  static void showAddClassDialog(BuildContext context, WidgetRef ref, {int? initialDay, TimetableModel? initialSlot}) {
    final roomController = TextEditingController(text: initialSlot?.room ?? '');
    final subjectController = TextEditingController(text: initialSlot?.subject ?? '');
    final codeController = TextEditingController(text: initialSlot?.subjectCode ?? '');
    int day = initialSlot?.dayOfWeek ?? initialDay ?? (DateTime.now().weekday <= 6 ? DateTime.now().weekday : 1);
    TimeOfDay startTime = initialSlot != null
        ? TimeOfDay(hour: initialSlot.startMinutes ~/ 60, minute: initialSlot.startMinutes % 60)
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = initialSlot != null
        ? TimeOfDay(hour: initialSlot.endMinutes ~/ 60, minute: initialSlot.endMinutes % 60)
        : const TimeOfDay(hour: 10, minute: 0);
    String? errorText;

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
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final subjectsAsync = ref.watch(attendanceStreamProvider);
          
          return subjectsAsync.when(
            data: (subjects) {
              return StatefulBuilder(
                builder: (ctx, setDialogState) => AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: Text(initialSlot == null ? 'Add Class' : 'Edit Class', style: const TextStyle(fontWeight: FontWeight.w600)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (errorText != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],
                        TextField(
                          controller: subjectController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            hintText: 'e.g. Data Structures',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Subject Code (optional)',
                            hintText: 'e.g. CS201',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        if (subjects.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Tap to reuse a subject', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: subjects.map((s) {
                              return GestureDetector(
                                onTap: () => setDialogState(() {
                                  subjectController.text = s.subject;
                                  codeController.text = s.subjectCode;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                  ),
                                  child: Text(
                                    s.subjectCode.trim().isEmpty ? s.subject : '${s.subject} (${s.subjectCode})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
                        final name = subjectController.text.trim();
                        final code = codeController.text.trim();
                        if (name.isEmpty) {
                          setDialogState(() => errorText = 'Please enter a subject name.');
                          return;
                        }

                        final startMins = startTime.hour * 60 + startTime.minute;
                        final endMins = endTime.hour * 60 + endTime.minute;
                        if (endMins <= startMins) {
                          setDialogState(() => errorText = 'End time must be after the start time.');
                          return;
                        }

                        final userId = ref.read(currentUserIdProvider);
                        if (userId != null) {
                          // Reuse an existing subject if it matches by code or name,
                          // otherwise create it so attendance tracks it too.
                          final matches = subjects.where((s) =>
                              (code.isNotEmpty && s.subjectCode.toLowerCase() == code.toLowerCase()) ||
                              s.subject.toLowerCase() == name.toLowerCase());
                          final String finalName;
                          final String finalCode;
                          if (matches.isNotEmpty) {
                            finalName = matches.first.subject;
                            finalCode = matches.first.subjectCode;
                          } else {
                            finalName = name;
                            finalCode = code;
                            ref.read(attendanceRepoProvider).addSubject(
                                  userId: userId,
                                  subject: name,
                                  subjectCode: code,
                                );
                          }

                          if (initialSlot == null) {
                            final slot = TimetableModel(
                              id: '', subject: finalName, subjectCode: finalCode,
                              dayOfWeek: day, startMinutes: startMins, endMinutes: endMins,
                              room: roomController.text.trim(), createdAt: DateTime.now(), updatedAt: DateTime.now(),
                            );
                            ref.read(timetableRepoProvider).addSlot(userId: userId, slot: slot);
                            _showSwipeTipIfNeeded(context, ref);
                          } else {
                            final slot = TimetableModel(
                              id: initialSlot.id, subject: finalName, subjectCode: finalCode,
                              dayOfWeek: day, startMinutes: startMins, endMinutes: endMins,
                              room: roomController.text.trim(), createdAt: initialSlot.createdAt, updatedAt: DateTime.now(),
                            );
                            ref.read(timetableRepoProvider).updateSlot(userId: userId, slot: slot);
                          }
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(initialSlot == null ? 'Add Class' : 'Save Changes'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (e, _) => const Center(child: Text('Error loading subjects')),
          );
        },
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
                  final earliest = due.isBefore(DateTime.now()) ? due : DateTime.now();
                  final d = await showDatePicker(context: ctx, initialDate: due, firstDate: earliest, lastDate: DateTime.now().add(const Duration(days: 365)));
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
                      _showSwipeTipIfNeeded(context, ref);
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
                        _showSwipeTipIfNeeded(context, ref);
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
