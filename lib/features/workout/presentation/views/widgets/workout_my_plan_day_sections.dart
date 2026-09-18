import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutMyPlanDaySelector extends StatelessWidget {
  const WorkoutMyPlanDaySelector({
    super.key,
    required this.days,
    required this.selectedDayNumber,
    required this.onSelected,
  });

  final List<PlanDayEntry> days;
  final int selectedDayNumber;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (_, _) => SizedBox(width: 9.w),
        itemBuilder: (context, index) {
          final day = days[index];
          return _DayChip(
            key: ValueKey(day.id),
            day: day,
            selected: day.dayNumber == selectedDayNumber,
            onTap: () => onSelected(day.dayNumber),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final PlanDayEntry day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryPurple : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          constraints: BoxConstraints(minWidth: 92.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day ${day.dayNumber}',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                day.isRest ? 'Rest' : day.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meduim12(context).copyWith(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutMyPlanRestDay extends StatelessWidget {
  const WorkoutMyPlanRestDay({super.key, required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bedtime_outlined,
            color: AppColors.primaryPurple,
            size: 36.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            note.trim().isNotEmpty
                ? note.trim()
                : 'Recover and get ready for your next training day.',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class WorkoutMyPlanEmptyDay extends StatelessWidget {
  const WorkoutMyPlanEmptyDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'No exercises are assigned to this day.',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
