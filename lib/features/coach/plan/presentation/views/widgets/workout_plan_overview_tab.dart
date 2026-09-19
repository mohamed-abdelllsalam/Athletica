import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/core/widgets/workout_plan_day_card.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

class CoachWorkoutPlanOverviewTab extends StatelessWidget {
  const CoachWorkoutPlanOverviewTab({
    super.key,
    required this.descriptionController,
    required this.template,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onToggleRest,
    required this.onRenameDay,
    required this.onReorderDays,
    required this.onNavigateDay,
    required this.onAddExercises,
    required this.onSaveTitle,
  });

  final TextEditingController descriptionController;
  final WorkoutTemplateEntry template;
  final VoidCallback onAddDay;
  final ValueChanged<TemplateDayEntry> onRemoveDay;
  final ValueChanged<TemplateDayEntry> onToggleRest;
  final ValueChanged<TemplateDayEntry> onRenameDay;
  final void Function(List<TemplateDayEntry> days, int oldIndex, int newIndex)
  onReorderDays;
  final ValueChanged<TemplateDayEntry> onNavigateDay;
  final ValueChanged<TemplateDayEntry> onAddExercises;
  final VoidCallback onSaveTitle;

  List<WorkoutPlanDayMenuAction> _menuFor(TemplateDayEntry day) => [
    if (!day.isRest)
      const WorkoutPlanDayMenuAction(
        value: 'add',
        label: 'Add exercises',
        icon: Icons.add,
      ),
    WorkoutPlanDayMenuAction(
      value: 'rest',
      label: day.isRest ? 'Remove rest day' : 'Make as a rest day',
      icon: day.isRest ? Icons.bedtime : Icons.bedtime_outlined,
    ),
    const WorkoutPlanDayMenuAction(
      value: 'rename',
      label: 'Rename',
      icon: Icons.edit_outlined,
    ),
    const WorkoutPlanDayMenuAction(
      value: 'delete',
      label: 'Delete',
      icon: Icons.delete_outline,
      danger: true,
    ),
  ];

  void _onMenu(TemplateDayEntry day, String value) {
    switch (value) {
      case 'add':
        onAddExercises(day);
      case 'rest':
        onToggleRest(day);
      case 'rename':
        onRenameDay(day);
      case 'delete':
        onRemoveDay(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Description is synced from the server via the BlocListener above.
    final days = [...template.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: descriptionController,
          maxLines: null,
          onSubmitted: (_) => onSaveTitle(),
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textTertiary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Program Days',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onAddDay,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.buttonColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.buttonColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Days',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.buttonColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (days.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No days yet — tap + Add Days',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) =>
                onReorderDays(days, oldIndex, newIndex),
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(14.r),
                child: child,
              ),
              child: child,
            ),
            children: [
              for (var i = 0; i < days.length; i++)
                Container(
                  key: ValueKey(days[i].id),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            Icons.drag_handle,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: WorkoutPlanDayCard(
                          dayLabel: 'D${days[i].dayNumber}',
                          title: days[i].title,
                          subtitle: days[i].isRest
                              ? 'Rest day'
                              : '${days[i].exerciseCount} Exercises',
                          isRest: days[i].isRest,
                          color:
                              workoutPlanDayColors[i %
                                  workoutPlanDayColors.length],
                          onNavigate: () => onNavigateDay(days[i]),
                          actions: _menuFor(days[i]),
                          onMenuSelected: (v) => _onMenu(days[i], v),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
