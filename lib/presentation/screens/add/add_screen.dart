import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../widgets/quick_add_dialogs.dart';

class AddScreen extends ConsumerWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      {
        'icon': LucideIcons.bookOpen,
        'title': 'Add Class',
        'desc': 'Add a new class to your timetable',
        'colors': [AppColors.primary, AppColors.primaryLight],
        'action': () {
          context.pop();
          QuickAddDialogs.showAddClassDialog(context, ref);
        }
      },
      {
        'icon': LucideIcons.fileText,
        'title': 'Add Assignment',
        'desc': 'Create a new assignment or task',
        'colors': [AppColors.success, AppColors.accentTealLight],
        'action': () {
          context.pop();
          QuickAddDialogs.showAddTaskDialog(context, ref);
        }
      },
      {
        'icon': LucideIcons.stickyNote,
        'title': 'Add Note',
        'desc': 'Write a new study note',
        'colors': [AppColors.primary, AppColors.primaryDark],
        'action': () {
          context.pop();
          QuickAddDialogs.showAddNoteEditor(context);
        }
      },
      {
        'icon': LucideIcons.calendar,
        'title': 'Mark Attendance',
        'desc': 'Add a new subject to track',
        'colors': [AppColors.orange500, AppColors.orange700],
        'action': () {
          context.pop();
          QuickAddDialogs.showAddSubjectDialog(context, ref);
        }
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Add", style: TextStyle(fontSize: 28, letterSpacing: -0.5, color: AppColors.textMain)),
                    SizedBox(height: 8),
                    Text("What would you like to add?", style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...actions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: action['action'] as VoidCallback,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100, width: 1),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: action['colors'] as List<Color>),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: (action['colors'] as List<Color>).first.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Center(child: Icon(action['icon'] as IconData, color: Colors.white, size: 28)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(action['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                                  const SizedBox(height: 4),
                                  Text(action['desc'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, color: AppColors.textTertiary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  )),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
