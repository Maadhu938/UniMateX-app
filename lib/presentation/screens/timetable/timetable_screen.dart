import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/timetable_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/quick_add_dialogs.dart';
import '../../widgets/empty_state.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});
  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late int selectedDay;

  final days = [
    {'id': 1, 'label': 'MON', 'full': 'Monday'},
    {'id': 2, 'label': 'TUE', 'full': 'Tuesday'},
    {'id': 3, 'label': 'WED', 'full': 'Wednesday'},
    {'id': 4, 'label': 'THU', 'full': 'Thursday'},
    {'id': 5, 'label': 'FRI', 'full': 'Friday'},
    {'id': 6, 'label': 'SAT', 'full': 'Saturday'},
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    selectedDay = (today >= 1 && today <= 6) ? today : 1;
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: timetableAsync.when(
          data: (_) => _buildContent(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildContent(BuildContext context) {
    final classes = ref.watch(classesByDayProvider(selectedDay));
    final selectedDayName = days.firstWhere((d) => d['id'] == selectedDay)['full'] as String;
    final allClasses = ref.watch(timetableStreamProvider).valueOrNull ?? const <TimetableModel>[];
    final classCountByDay = <int, int>{};
    for (final c in allClasses) {
      classCountByDay[c.dayOfWeek] = (classCountByDay[c.dayOfWeek] ?? 0) + 1;
    }
    final todayWeekday = DateTime.now().weekday;
    final isToday = selectedDay == todayWeekday;
    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;

    // When viewing today, work out which class is ongoing or up next.
    int? ongoingIndex;
    int? nextIndex;
    if (isToday) {
      for (var i = 0; i < classes.length; i++) {
        if (nowMinutes >= classes[i].startMinutes && nowMinutes < classes[i].endMinutes) {
          ongoingIndex = i;
          break;
        }
      }
      if (ongoingIndex == null) {
        for (var i = 0; i < classes.length; i++) {
          if (classes[i].startMinutes > nowMinutes) {
            nextIndex = i;
            break;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.timetable,
                      style: TextStyle(
                        fontSize: 28,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppStrings.timetableSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => QuickAddDialogs.showAddClassDialog(context, ref, initialDay: selectedDay),
                    icon: const Icon(LucideIcons.plus),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
            ],
          ),
        ),

        
        // Days Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: days.map((day) {
              final dayId = day['id'] as int;
              final isSelected = selectedDay == dayId;
              final count = classCountByDay[dayId] ?? 0;
              final isTodayChip = dayId == todayWeekday;

              final labelColor = isSelected
                  ? Colors.white
                  : (isTodayChip ? AppColors.primary : AppColors.textSecondary);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedDay = dayId),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primary.withOpacity(0.88)])
                          : null,
                      color: isSelected ? null : (isTodayChip ? AppColors.primary.withOpacity(0.07) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isTodayChip ? AppColors.primary.withOpacity(0.35) : Colors.grey.shade200),
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          day['label'] as String,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: labelColor),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 18,
                          child: count > 0
                              ? Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(minWidth: 18),
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.22) : AppColors.primary.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.primary),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? Colors.white.withOpacity(0.4) : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "$selectedDayName • ${classes.length} ${classes.length == 1 ? 'Class' : 'Classes'}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Expanded(
          child: classes.isEmpty
            ? EmptyState(
                icon: LucideIcons.calendar,
                title: AppStrings.noClasses,
                description: AppStrings.addClassDesc,
                actionLabel: AppStrings.addClass,
                onAction: () => QuickAddDialogs.showAddClassDialog(context, ref, initialDay: selectedDay),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 80),
                children: classes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == classes.length - 1;
                  final status = index == ongoingIndex
                      ? _ClassStatus.ongoing
                      : (index == nextIndex ? _ClassStatus.next : _ClassStatus.none);

                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Class?'),
                          content: Text('Are you sure you want to delete "${item.subject}" from your schedule?'),
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
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(LucideIcons.trash2, color: AppColors.danger),
                    ),
                    onDismissed: (_) {
                      HapticFeedback.mediumImpact();
                      final uid = ref.read(currentUserIdProvider);
                      if (uid != null) {
                        ref.read(timetableRepoProvider).deleteSlot(userId: uid, slotId: item.id);
                      }
                    },
                    child: _buildTimelineItem(context, item, status, isLast),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, TimetableModel item, _ClassStatus status, bool isLast) {
    final isOngoing = status == _ClassStatus.ongoing;
    final isNext = status == _ClassStatus.next;

    final nodeColor = isOngoing
        ? AppColors.primary
        : (isNext ? AppColors.amber600 : Colors.grey.shade300);

    final startH = item.startMinutes ~/ 60;
    final startM = item.startMinutes % 60;
    final period = startH >= 12 ? 'PM' : 'AM';
    var h12 = startH % 12;
    if (h12 == 0) h12 = 12;
    final startLabel = '$h12:${startM.toString().padLeft(2, '0')}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time rail
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(startLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isOngoing ? AppColors.primary : AppColors.textMain)),
                  Text(period, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Connector
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOngoing ? AppColors.primary : Colors.white,
                  border: Border.all(color: nodeColor, width: 2.5),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Class card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: GestureDetector(
                onTap: () => QuickAddDialogs.showAddClassDialog(context, ref, initialSlot: item),
                child: _buildClassCard(item, status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(TimetableModel item, _ClassStatus status) {
    final isLab = item.subject.toLowerCase().contains('lab') || item.room.toLowerCase().contains('lab');
    final typeText = isLab ? "Lab" : "Lecture";
    final typeColor = isLab ? AppColors.purple600 : AppColors.blue600;
    final typeBgStart = isLab ? AppColors.purple50 : AppColors.blue50;
    final typeBgEnd = isLab ? AppColors.violet50 : AppColors.blue100;
    final typeBorder = isLab ? AppColors.purple100 : AppColors.blue100;

    final isOngoing = status == _ClassStatus.ongoing;
    final isNext = status == _ClassStatus.next;

    final durationMins = (item.endMinutes - item.startMinutes).clamp(0, 24 * 60);
    final durH = durationMins ~/ 60;
    final durM = durationMins % 60;
    final durationText = durH > 0
        ? (durM > 0 ? '${durH}h ${durM}m' : '${durH}h')
        : '${durM}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isOngoing
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.07), Colors.white])
            : null,
        color: isOngoing ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOngoing ? AppColors.primary.withOpacity(0.4) : Colors.grey.shade100,
          width: isOngoing ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.subject,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [typeBgStart, typeBgEnd]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeBorder),
                ),
                child: Text(typeText, style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(item.timeString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Text('· $durationText', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              const Spacer(),
              if (isOngoing || isNext)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isOngoing ? AppColors.primary : AppColors.amber600).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOngoing ? 'Now' : 'Next',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isOngoing ? AppColors.primary : AppColors.amber600),
                  ),
                ),
            ],
          ),
          if (item.room.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(child: Text(item.room, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum _ClassStatus { none, ongoing, next }

