import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/core/widgets/workout_plan_day_card.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';

class WorkoutPlanCreateOverviewTab extends StatelessWidget {
  const WorkoutPlanCreateOverviewTab({
    super.key,
    required this.descriptionController,
    required this.descriptionHasError,
    required this.days,
    required this.onAddDay,
    required this.onOpenDay,
    required this.onToggleRest,
    required this.onReorder,
  });

  final TextEditingController descriptionController;
  final bool descriptionHasError;
  final List<ProgramDay> days;
  final VoidCallback onAddDay;
  final ValueChanged<int> onOpenDay;
  final ValueChanged<int> onToggleRest;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
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
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textTertiary),
            errorText: descriptionHasError ? 'Required' : null,
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
            onReorder: onReorder,
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
                  key: ValueKey(days[i]),
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
                        child: _CreateDayRow(
                          day: days[i],
                          color:
                              workoutPlanDayColors[i %
                                  workoutPlanDayColors.length],
                          onNavigate: () => onOpenDay(i),
                          onToggleRest: () => onToggleRest(i),
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

class _CreateDayRow extends StatelessWidget {
  const _CreateDayRow({
    required this.day,
    required this.color,
    required this.onNavigate,
    required this.onToggleRest,
  });

  final ProgramDay day;
  final Color color;
  final VoidCallback onNavigate;
  final VoidCallback onToggleRest;

  @override
  Widget build(BuildContext context) {
    return WorkoutPlanDayCard(
      dayLabel: 'D${day.dayNumber}',
      title: day.name,
      subtitle: day.isRest ? 'Rest day' : '${day.exerciseCount} Exercises',
      isRest: day.isRest,
      color: color,
      onNavigate: onNavigate,
      actions: [
        WorkoutPlanDayMenuAction(
          value: 'rest',
          label: day.isRest ? 'Remove rest day' : 'Make as a rest day',
          icon: day.isRest ? Icons.bedtime : Icons.bedtime_outlined,
        ),
      ],
      onMenuSelected: (_) => onToggleRest(),
    );
  }
}
