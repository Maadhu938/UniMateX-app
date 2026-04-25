import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/quick_add_dialogs.dart';
import '../../widgets/empty_state.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: attendanceAsync.when(
          data: (list) => _buildContent(context, ref, list),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                const Text('Failed to load attendance', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(attendanceStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<AttendanceModel> list) {
    final overallPct = ref.watch(overallAttendanceProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attendance", style: TextStyle(fontSize: 28, letterSpacing: -0.5, color: AppColors.textMain)),
                SizedBox(height: 8),
                Text("Track your class attendance", style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
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
        ),
        const SizedBox(height: 20),
        _buildOverallCard(overallPct),
        const SizedBox(height: 20),
        ...list.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSubjectCard(context, ref, item),
        )),
        if (list.isEmpty)
          EmptyState(
            icon: LucideIcons.trendingUp,
            title: "No subjects tracked",
            description: "Start tracking your attendance by adding your subjects.",
            actionLabel: "Add Subject",
            onAction: () => QuickAddDialogs.showAddSubjectDialog(context, ref),
          ),
      ],
    );
  }

  Widget _buildOverallCard(double overallPct) {
    final normalizedPct = overallPct.clamp(0.0, 1.0);
    final pct = (normalizedPct * 100).round();
    final safeValue = normalizedPct >= 1.0 ? 0.999 : normalizedPct;

    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;
    final String zoneLabel;

    if (normalizedPct < 0.75) {
      statusColor = AppColors.danger;
      statusBg = AppColors.red50;
      statusIcon = LucideIcons.trendingDown;
      zoneLabel = 'Danger Zone';
    } else if (normalizedPct < 0.85) {
      statusColor = AppColors.amber600;
      statusBg = AppColors.amber50;
      statusIcon = LucideIcons.activity;
      zoneLabel = 'Warning Zone';
    } else {
      statusColor = AppColors.success;
      statusBg = AppColors.green50;
      statusIcon = LucideIcons.trendingUp;
      zoneLabel = 'Safe Zone';
    }
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 180, height: 180, 
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160, height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 16,
                    color: Colors.grey.shade100,
                  ),
                ),
                SizedBox(
                  width: 160, height: 160,
                  child: CircularProgressIndicator(
                    value: safeValue,
                    strokeWidth: 16,
                    backgroundColor: Colors.transparent,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("$pct%", style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.0)),
                    const SizedBox(height: 4),
                    const Text("Overall", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(zoneLabel, style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, WidgetRef ref, AttendanceModel item) {
    final pct = (item.percentage * 100).round();
    final isSafe = pct >= 85;
    final isWarning = pct >= 75 && pct < 85;
    
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
      margin: const EdgeInsets.only(bottom: 16),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusLabel.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.attendedClasses}/${item.totalClasses} Classes',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Goal: 85%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Present → ${(item.percentageIfAttended * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.xCircle, color: AppColors.danger, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Absent → ${(item.percentageIfMissed * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                const Text(
                  "Action Plan",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (isSafe && item.classesToSkipSafely > 0)
                  Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "You can skip ${item.classesToSkipSafely} classes safely",
                        style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                else if (!isSafe && item.classesToReachSafeZone > 0)
                  Row(
                    children: [
                      Icon(isWarning ? LucideIcons.target : LucideIcons.trendingDown, 
                           color: isWarning ? AppColors.amber600 : AppColors.danger, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Attend next ${item.classesToReachSafeZone} classes to reach safe zone",
                          style: TextStyle(
                            color: isWarning ? AppColors.amber600 : AppColors.danger, 
                            fontSize: 12, fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        "You are in the safe zone",
                        style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),
          ),
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
                    onPressed: () => _markAttendance(ref, item.id, true),
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
                    onPressed: () => _markAttendance(ref, item.id, false),
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

  void _markAttendance(WidgetRef ref, String subjectId, bool attended) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    ref.read(attendanceRepoProvider).markClass(
          userId: userId,
          subjectId: subjectId,
          attended: attended,
        );
  }

}
