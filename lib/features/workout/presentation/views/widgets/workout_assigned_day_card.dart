import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutAssignedDayCard extends StatelessWidget {
  const WorkoutAssignedDayCard({
    super.key,
    required this.day,
    required this.exercises,
  });

  final PlanDayEntry day;
  final List<Widget> exercises;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Day ${day.dayNumber} — ${day.title}',
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (day.isRest)
                Text(
                  'Rest',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (!day.isRest && exercises.isEmpty)
            Text(
              'No exercises yet.',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            )
          else
            ...exercises,
        ],
      ),
    );
  }
}
