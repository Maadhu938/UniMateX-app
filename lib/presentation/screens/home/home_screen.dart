import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/timetable_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/quick_add_dialogs.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userDisplayNameProvider).valueOrNull ?? 'Student';
    final overallAttendance = ref.watch(overallAttendanceProvider);
    final attendanceData = ref.watch(attendanceStreamProvider).valueOrNull ?? [];
    final hasAttendanceData = attendanceData.any((a) => a.totalClasses > 0);
    final todayClasses = ref.watch(todayClassesProvider);
    final authState = ref.watch(authStateProvider);
    final assignments = ref.watch(assignmentStreamProvider).valueOrNull ?? [];
    
    final pendingCount = assignments.where((a) => a.isPending).length;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final overdueCount = assignments.where((a) {
      if (!a.isPending || a.dueDate == null) return false;
      final due = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
      return due.isBefore(today);
    }).length;

    final dueTodayCount = assignments.where((a) {
      if (!a.isPending || a.dueDate == null) return false;
      final due = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
      return due.isAtSameMomentAs(today);
    }).length;

    final thisWeekCount = assignments.where((a) {
      if (!a.isPending || a.dueDate == null) return false;
      final due = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
      final diff = due.difference(today).inDays;
      return diff > 0 && diff <= 7;
    }).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildHeader(context, ref, userName),
            const SizedBox(height: 20),
            _buildSmartWarnings(context, ref),
            _buildAttendanceCard(context, overallAttendance, hasAttendanceData),
            const SizedBox(height: 20),
            _buildTodayClasses(context, todayClasses),
            const SizedBox(height: 20),
            _buildAssignmentsCard(context, pendingCount, dueTodayCount, thisWeekCount),
            const SizedBox(height: 20),
            _buildQuickActions(context, ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

    Widget _buildHeader(BuildContext context, WidgetRef ref, String name) {
      final hour = DateTime.now().hour;
      String greeting = "Good evening";
      if (hour < 12) greeting = "Good morning";
      else if (hour < 18) greeting = "Good afternoon";

      final firstName = name.split(' ').first;
      final user = ref.watch(authStateProvider).valueOrNull;
      final photoUrl = user?.photoURL;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting,",
                    style: const TextStyle(fontSize: 28, height: 1.1, color: AppColors.textMain, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "$firstName 👋",
                    style: const TextStyle(fontSize: 28, height: 1.1, color: AppColors.textMain, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Here's your day at a glance",
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    image: photoUrl != null ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) : null,
                  ),
                  child: photoUrl == null 
                    ? Center(child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)))
                    : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildSmartWarnings(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(attendanceStreamProvider).valueOrNull ?? [];
    final assignments = ref.watch(assignmentStreamProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Widget> warnings = [];

    // Attendance Warnings
    for (var a in attendance) {
      if (a.percentage < 0.75) {
        warnings.add(_buildWarningCard(
          icon: LucideIcons.alertCircle,
          color: AppColors.danger,
          title: "Danger Zone",
          message: "Your ${a.subject} attendance is ${(a.percentage * 100).round()}%. Next class impact: Miss → ${(a.percentageIfMissed * 100).toStringAsFixed(1)}% | Attend → ${(a.percentageIfAttended * 100).toStringAsFixed(1)}%.",
          bgColor: AppColors.red50,
          borderColor: AppColors.red100,
        ));
      } else if (a.percentage < 0.85) {
        warnings.add(_buildWarningCard(
          icon: LucideIcons.alertTriangle,
          color: AppColors.amber600,
          title: "Attendance Dropping",
          message: "${a.subject} is at ${(a.percentage * 100).round()}% — don't skip the next class.",
          bgColor: AppColors.amber50,
          borderColor: AppColors.amber100,
        ));
      }
    }

    // Assignments Warnings
    for (var a in assignments) {
      if (a.isPending && a.dueDate != null) {
        final due = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
        final diff = due.difference(today).inDays;
        if (diff == 0) {
           warnings.add(_buildWarningCard(
             icon: LucideIcons.clock,
             color: AppColors.danger,
             title: "Due Today",
             message: "Assignment '${a.title}' is due today!",
             bgColor: AppColors.red50,
             borderColor: AppColors.red100,
           ));
        } else if (diff == 1) {
           warnings.add(_buildWarningCard(
             icon: LucideIcons.calendar,
             color: AppColors.amber600,
             title: "Due Tomorrow",
             message: "Assignment '${a.title}' is due tomorrow.",
             bgColor: AppColors.amber50,
             borderColor: AppColors.amber100,
           ));
        } else if (diff < 0) {
           warnings.add(_buildWarningCard(
             icon: LucideIcons.flag,
             color: AppColors.danger,
             title: "Overdue",
             message: "Assignment '${a.title}' is overdue!",
             bgColor: AppColors.red50,
             borderColor: AppColors.red100,
           ));
        }
      }
    }

    if (warnings.isEmpty) {
       return Container(
         width: double.infinity,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(
           color: AppColors.primary.withOpacity(0.02),
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: AppColors.primary.withOpacity(0.05)),
         ),
         child: Row(
           children: [
             Icon(LucideIcons.sparkles, color: AppColors.primary.withOpacity(0.5), size: 24),
             const SizedBox(width: 16),
             const Expanded(
               child: Text(
                 "Everything looks great! No warnings or urgent tasks for now.",
                 style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
               ),
             ),
           ],
         ),
       );
    }

    final displayWarnings = warnings.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text("Smart Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          ],
        ),
        const SizedBox(height: 12),
        ...displayWarnings.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWarningCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 13, color: AppColors.textMain.withOpacity(0.8), height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, double attendancePct, bool hasAttendanceData) {
    final normalizedPct = attendancePct.clamp(0.0, 1.0);
    final pct = (normalizedPct * 100).round();
    final safeValue = normalizedPct >= 1.0 ? 0.999 : normalizedPct;

    final Color statusColor;
    final Color statusBg;
    final IconData trendIcon;
    final String zoneLabel;
    final String zoneMessage;

    if (!hasAttendanceData) {
      statusColor = AppColors.primary;
      statusBg = AppColors.primary.withOpacity(0.1);
      trendIcon = LucideIcons.info;
      zoneLabel = 'No Data Yet';
      zoneMessage = 'Add attendance records to see your zone.';
    } else if (normalizedPct < 0.75) {
      statusColor = AppColors.danger;
      statusBg = AppColors.red50;
      trendIcon = LucideIcons.trendingDown;
      zoneLabel = 'Danger Zone';
      zoneMessage = 'Immediate attention needed.';
    } else if (normalizedPct < 0.85) {
      statusColor = AppColors.amber600;
      statusBg = AppColors.amber50;
      trendIcon = LucideIcons.activity;
      zoneLabel = 'Warning Zone';
      zoneMessage = 'Try to attend upcoming classes.';
    } else {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withOpacity(0.1);
      trendIcon = LucideIcons.trendingUp;
      zoneLabel = 'Safe Zone';
      zoneMessage = 'Keep up the good work!';
    }
    
    return GestureDetector(
      onTap: () => context.go('/attendance'),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Overall Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                    const SizedBox(height: 2),
                    const Text("Across all subjects", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
                  child: Center(child: Icon(trendIcon, color: statusColor, size: 20)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 340;
                final ringSize = isCompact ? 96.0 : 112.0;
                final ringStroke = isCompact ? 9.0 : 10.0;
                final ringTextSize = isCompact ? 19.0 : 22.0;
                final rowGap = isCompact ? 12.0 : 24.0;

                return Row(
                  children: [
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size.square(ringSize),
                            painter: _AttendanceRingPainter(
                              progress: safeValue,
                              trackColor: Colors.grey.shade100,
                              progressColor: statusColor,
                              strokeWidth: ringStroke,
                            ),
                          ),
                          Text(
                            "$pct%",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ringTextSize,
                              fontWeight: FontWeight.w700,
                              height: 1,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: rowGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 12 : 14,
                              vertical: isCompact ? 6 : 7,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    zoneLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: isCompact ? 13 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            zoneMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTodayClasses(BuildContext context, List<TimetableModel> classes) {
    return GestureDetector(
      onTap: () => context.go('/timetable'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
                  child: const Center(child: Icon(LucideIcons.calendar, color: AppColors.primary, size: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (classes.isEmpty)
               const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.coffee, color: AppColors.textTertiary, size: 32),
                      SizedBox(height: 12),
                      Text("No classes today! Relax ☕", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: classes.map((cls) {
                  final parts = cls.timeString.split(' ');
                  final timePart = parts.isNotEmpty ? parts[0] : '';
                  final ampmPart = parts.length > 1 ? parts[1] : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade50, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: Column(
                            children: [
                              Text(timePart, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                              Text(ampmPart, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1, height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.grey.shade200, Colors.transparent],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cls.subject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(cls.room, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsCard(BuildContext context, int pending, int dueToday, int thisWeek) {
    return GestureDetector(
      onTap: () => context.go('/assignments'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pending Assignments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
                  child: const Center(child: Icon(LucideIcons.fileText, color: AppColors.primary, size: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (pending == 0) ...[
                  const Text("All caught up!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.success)),
                  const SizedBox(width: 8),
                  const Text("✨", style: TextStyle(fontSize: 20)),
                ] else ...[
                  Text("$pending", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                  const SizedBox(width: 8),
                  const Text("tasks this week", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.red50, Colors.white]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.red100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$dueToday", style: const TextStyle(color: AppColors.danger, fontSize: 18, fontWeight: FontWeight.w600)),
                        Text("Due Today", style: TextStyle(color: AppColors.danger.withOpacity(0.7), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.amber50, Colors.white]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.amber200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$thisWeek", style: const TextStyle(color: AppColors.amber600, fontSize: 18, fontWeight: FontWeight.w600)),
                        Text("This Week", style: TextStyle(color: AppColors.amber600.withOpacity(0.7), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         border: Border.all(color: Colors.grey.shade100, width: 1),
         boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
         ],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
           const SizedBox(height: 16),
           Row(
             children: [
               Expanded(
                 flex: 1,
                 child: _buildActionBtn(
                   LucideIcons.plus, 
                   "Add Class",
                   () => QuickAddDialogs.showAddClassDialog(context, ref),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 flex: 1,
                 child: _buildActionBtn(
                   LucideIcons.plus, 
                   "Add Task",
                   () => QuickAddDialogs.showAddTaskDialog(context, ref),
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.05), AppColors.primary.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: AppColors.primary, size: 20)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _AttendanceRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final clampedProgress = progress.clamp(0.0, 0.999);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * clampedProgress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AttendanceRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}



