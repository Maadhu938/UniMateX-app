import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/timetable_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/repository_providers.dart';
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
    {'id': 1, 'label': 'Mon', 'full': 'Monday'},
    {'id': 2, 'label': 'Tue', 'full': 'Tuesday'},
    {'id': 3, 'label': 'Wed', 'full': 'Wednesday'},
    {'id': 4, 'label': 'Thu', 'full': 'Thursday'},
    {'id': 5, 'label': 'Fri', 'full': 'Friday'},
    {'id': 6, 'label': 'Sat', 'full': 'Saturday'},
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Timetable", style: TextStyle(fontSize: 28, letterSpacing: -0.5, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      const Text("Your weekly class schedule", style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ],
                  ),
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
            ],
          ),
        ),
        
        // Days Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: days.map((day) {
              final isSelected = selectedDay == day['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => selectedDay = day['id'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)]) : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200, width: 1),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                    ),
                    child: Text(
                      day['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "$selectedDayName • ${classes.length} ${classes.length == 1 ? 'Class' : 'Classes'}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
            children: classes.isEmpty
              ? [
                  EmptyState(
                    icon: LucideIcons.calendar,
                    title: "No classes today",
                    description: "You have a free day! Or maybe you haven't added your classes yet?",
                    actionLabel: "Add Class",
                    onAction: () => QuickAddDialogs.showAddClassDialog(context, ref, initialDay: selectedDay),
                  ),
                ]
              : classes.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildClassCard(item),
                )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(TimetableModel item) {
    // Derive type
    final isLab = item.subject.toLowerCase().contains('lab') || item.room.toLowerCase().contains('lab');
    final typeText = isLab ? "Lab" : "Lecture";
    
    final typeColor = isLab ? AppColors.purple600 : AppColors.blue600;
    final typeBgStart = isLab ? AppColors.purple50 : AppColors.blue50;
    final typeBgEnd = isLab ? AppColors.violet50 : AppColors.blue100;
    final typeBorder = isLab ? AppColors.purple100 : AppColors.blue100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
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
                    Text(item.subject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(item.room, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [typeBgStart, typeBgEnd]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeBorder),
                ),
                child: Text(typeText, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.grey.shade50, Colors.grey.shade50.withOpacity(0.5)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.clock, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(item.timeString, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

