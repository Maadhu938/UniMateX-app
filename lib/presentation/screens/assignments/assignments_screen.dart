import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/assignment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/quick_add_dialogs.dart';
import '../../widgets/empty_state.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  String activeTab = 'pending'; // 'all', 'pending', 'completed'

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(assignmentStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: asyncData.when(
          data: (_) => _buildContent(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildContent(BuildContext context) {
    final items = ref.watch(assignmentsByStatusProvider(activeTab));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assignments", style: TextStyle(fontSize: 28, letterSpacing: -0.5, color: AppColors.textMain)),
                SizedBox(height: 8),
                Text("Track your tasks and deadlines", style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              ],
            ),
            IconButton.filled(
              onPressed: () => QuickAddDialogs.showAddTaskDialog(context, ref),
              icon: const Icon(LucideIcons.plus),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Custom Tabs
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: ['all', 'pending', 'completed'].map((tab) {
              final isActive = activeTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => activeTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isActive ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)]) : null,
                      borderRadius: BorderRadius.circular(14),
                      color: isActive ? null : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab[0].toUpperCase() + tab.substring(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 20),
        
        if (items.isEmpty)
          EmptyState(
            icon: LucideIcons.fileText,
            title: "No assignments found",
            description: "You're all caught up! Or you can add a new task to stay organized.",
            actionLabel: "Add Assignment",
            onAction: () => QuickAddDialogs.showAddTaskDialog(context, ref),
          )
        else
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAssignmentCard(item),
          )),
      ],
    );
  }

  Widget _buildAssignmentCard(AssignmentModel item) {
    final isCompleted = item.isCompleted;
    
    // Calculate days until due
    String daysText = "";
    Color badgeColor = AppColors.primary;
    Color bgGradientStart = AppColors.blue50;
    Color bgGradientEnd = AppColors.blue100;
    Color borderCol = AppColors.primary.withOpacity(0.2);
    IconData? badgeIcon;

    if (!isCompleted && item.dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(item.dueDate!.year, item.dueDate!.month, item.dueDate!.day);
      final diffDays = due.difference(today).inDays;

      if (diffDays == 0) {
        daysText = "Today";
        badgeColor = AppColors.danger;
        bgGradientStart = AppColors.red50;
        bgGradientEnd = AppColors.rose50;
        borderCol = AppColors.danger.withOpacity(0.2);
        badgeIcon = LucideIcons.flag;
      } else if (diffDays == 1) {
        daysText = "Tomorrow";
        badgeColor = AppColors.amber600;
        bgGradientStart = AppColors.amber50;
        bgGradientEnd = AppColors.yellow50;
        borderCol = AppColors.amber200;
        badgeIcon = LucideIcons.clock;
      } else if (diffDays < 0) {
        daysText = "Overdue";
        badgeColor = AppColors.danger;
        bgGradientStart = AppColors.red50;
        bgGradientEnd = AppColors.rose50;
        borderCol = AppColors.danger.withOpacity(0.2);
        badgeIcon = LucideIcons.flag;
      } else {
        daysText = "$diffDays days";
      }
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
        child: const Icon(LucideIcons.trash2, color: AppColors.danger),
      ),
      onDismissed: (_) {
        final uid = ref.read(currentUserIdProvider);
        if (uid != null) ref.read(assignmentRepoProvider).deleteAssignment(userId: uid, assignmentId: item.id);
      },
      child: GestureDetector(
        onTap: () => QuickAddDialogs.showAddTaskDialog(context, ref, initialTask: item),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Opacity(
            opacity: isCompleted ? 0.6 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? AppColors.textSecondary : AppColors.textMain,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.subject.isNotEmpty ? item.subject : (item.description.isNotEmpty ? item.description : 'No subject'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggle(item),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          gradient: isCompleted 
                            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.green400, AppColors.emerald500])
                            : null,
                          color: isCompleted ? null : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isCompleted ? Colors.transparent : Colors.grey.shade300, width: 2),
                          boxShadow: isCompleted ? [BoxShadow(color: AppColors.success.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : [],
                        ),
                        child: Center(
                          child: Icon(
                            isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle, 
                            color: isCompleted ? Colors.white : Colors.grey.shade300, 
                            size: 20
                          )
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.calendar, color: AppColors.textSecondary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            item.dueDate != null ? DateFormat('MMM d').format(item.dueDate!) : 'No date',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!isCompleted && daysText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bgGradientStart, bgGradientEnd]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (badgeIcon != null) ...[
                              Icon(badgeIcon, color: badgeColor, size: 14),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              daysText,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: badgeColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(AssignmentModel item) {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    ref.read(assignmentRepoProvider).updateStatus(
      userId: uid, assignmentId: item.id, status: item.isPending ? 'completed' : 'pending');
  }
}

