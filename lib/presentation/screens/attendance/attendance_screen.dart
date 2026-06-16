import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/bunk_calculator.dart';
import '../../../domain/models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/quick_add_dialogs.dart';
import '../../widgets/empty_state.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final Set<String> _expandedIds = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: attendanceAsync.when(
          data: (list) => _buildContent(context, list),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildContent(BuildContext context, List<AttendanceModel> list) {
    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.attendance,
              style: TextStyle(
                fontSize: 28,
                letterSpacing: -0.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Track your class attendance",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
        IconButton.filled(
          onPressed: () => QuickAddDialogs.showAddSubjectDialog(context, ref),
          icon: const Icon(LucideIcons.plus),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );

    if (list.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: header,
          ),
          Expanded(
            child: EmptyState(
              icon: LucideIcons.trendingUp,
              title: AppStrings.noSubjects,
              description: AppStrings.addSubjectDesc,
              actionLabel: AppStrings.addSubject,
              onAction: () => QuickAddDialogs.showAddSubjectDialog(context, ref),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: header,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
            children: list.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Subject?'),
                    content: Text('Are you sure you want to delete "${item.subject}"? All attendance data for this subject will be lost.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true), 
                        style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(LucideIcons.trash2, color: AppColors.danger),
              ),
              onDismissed: (_) {
                HapticFeedback.mediumImpact();
                final uid = ref.read(currentUserIdProvider);
                if (uid != null) {
                  ref.read(attendanceRepoProvider).deleteSubject(userId: uid, subjectId: item.id);
                }
              },
              child: _buildSubjectCard(context, item),
            ),
          )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, AttendanceModel item) {
    final pct = (item.percentage * 100).round();
    final target = item.targetPercentage;
    final warningThreshold = (target - 0.10).clamp(0.0, 1.0);
    final isSafe = item.percentage >= target;
    final isWarning = item.percentage >= warningThreshold && item.percentage < target;
    final isExpanded = _expandedIds.contains(item.id);
    
    final now = DateTime.now();
    final markedToday = item.lastMarkedDate != null && 
        item.lastMarkedDate!.year == now.year &&
        item.lastMarkedDate!.month == now.month &&
        item.lastMarkedDate!.day == now.day;
    
    Color statusColor = AppColors.danger;
    Color borderCol = AppColors.danger.withOpacity(0.2);
    
    if (isSafe) {
      statusColor = AppColors.success;
      borderCol = AppColors.success.withOpacity(0.2);
    } else if (isWarning) {
      statusColor = AppColors.amber600;
      borderCol = AppColors.amber200;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subjectCode,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$pct%',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.statusLabel == 'danger'
                          ? AppColors.danger
                          : statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusLabel.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.statusLabel == 'danger' ? Colors.white : statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showSubjectSettingsDialog(context, item),
                icon: const Icon(LucideIcons.settings2, size: 18, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.percentage,
              backgroundColor: statusColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.attendedClasses}/${item.totalClasses} Classes',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              // Dropdown Toggle Button
              InkWell(
                onTap: () => _toggleExpanded(item.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        isExpanded ? "Hide details" : "Show impact",
                        style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 16,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Collapsible Impact Section
          if (isExpanded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Class Impact",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  _buildImpactInfo(item),
                  const SizedBox(height: 12),
                  _buildPercentagesRow(item),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.black12),
                  ),
                  const Text(
                    "Action Plan",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${(item.targetPercentage * 100).round()}% | Semester Goal: ${item.totalClassesInSemester ?? 'Not set'}',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          if (markedToday)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(LucideIcons.checkCircle2, size: 18),
                label: const Text('Attendance marked for today'),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: AppColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.grey.shade50,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAttendance(item.id, true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Present'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAttendance(item.id, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Absent'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImpactInfo(AttendanceModel item) {
    final bunkable = BunkCalculator.canBunk(present: item.attendedClasses, total: item.totalClasses, target: item.targetPercentage);
    final needed = BunkCalculator.classesNeeded(present: item.attendedClasses, total: item.totalClasses, target: item.targetPercentage);
    final remaining = item.totalClassesInSemester != null ? (item.totalClassesInSemester! - item.totalClasses) : null;
    final isCritical = needed > 0 && remaining != null && remaining <= needed;

    if (item.totalClasses == 0) {
      return const Row(children: [Icon(LucideIcons.info, color: AppColors.textSecondary, size: 14), SizedBox(width: 6), Text('No classes tracked yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))]);
    }
    if (bunkable > 0) {
      return Row(children: [const Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 14), const SizedBox(width: 6), Text('You can safely bunk $bunkable more classes', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600))]);
    }
    if (isCritical) {
      return const Row(children: [Icon(LucideIcons.alertTriangle, color: AppColors.danger, size: 14), SizedBox(width: 6), Expanded(child: Text(AppStrings.critical, style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)))]);
    }
    if (needed > 0) {
      return Row(children: [const Icon(LucideIcons.target, color: AppColors.amber600, size: 14), const SizedBox(width: 6), Expanded(child: Text(AppStrings.needMore.replaceAll('{count}', needed.toString()), style: const TextStyle(color: AppColors.amber600, fontSize: 12, fontWeight: FontWeight.w600)))]);
    }
    return const Row(children: [Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 14), SizedBox(width: 6), Text(AppStrings.safeZone, style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600))]);
  }

  Widget _buildPercentagesRow(AttendanceModel item) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 14), const SizedBox(width: 4), Text("Present → ${(item.percentageIfAttended * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain))]),
        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.xCircle, color: AppColors.danger, size: 14), const SizedBox(width: 4), Text("Absent → ${(item.percentageIfMissed * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain))]),
      ],
    );
  }

  void _markAttendance(String subjectId, bool attended) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    ref.read(attendanceRepoProvider).markClass(userId: userId, subjectId: subjectId, attended: attended);
  }

  Future<void> _showSubjectSettingsDialog(BuildContext context, AttendanceModel item) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    double selectedTarget = item.targetPercentage;
    final semesterController = TextEditingController(text: item.totalClassesInSemester?.toString() ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppStrings.subjectSettings.replaceAll('{name}', item.subject)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<double>(
                value: selectedTarget,
                decoration: InputDecoration(labelText: AppStrings.targetPct, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: const [DropdownMenuItem(value: 0.75, child: Text('75%')), DropdownMenuItem(value: 0.80, child: Text('80%')), DropdownMenuItem(value: 0.85, child: Text('85%'))],
                onChanged: (value) { if (value != null) setDialogState(() => selectedTarget = value); },
              ),
              const SizedBox(height: 12),
              TextField(controller: semesterController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.semesterTotal, hintText: AppStrings.egClasses, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () {
                final raw = semesterController.text.trim();
                ref.read(attendanceRepoProvider).updateSubjectSettings(userId: userId, subjectId: item.id, targetPercentage: selectedTarget, totalClassesInSemester: int.tryParse(raw), clearSemesterTotal: raw.isEmpty);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}
