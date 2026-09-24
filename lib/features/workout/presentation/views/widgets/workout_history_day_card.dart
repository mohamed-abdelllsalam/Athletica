import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutHistoryDayCard extends StatelessWidget {
  const WorkoutHistoryDayCard({
    super.key,
    required this.day,
    required this.completed,
    required this.dot,
    required this.status,
  });

  final WorkoutHistoryDay day;
  final bool completed;
  final Color dot;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.date} • Day ${day.dayNumber} — ${day.title}',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${day.completedExercises}/${day.totalExercises} • $status',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (day.isRest)
            Text(
              'R',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.streakBlue),
            )
          else if (completed)
            Icon(Icons.check_circle, color: AppColors.streakGreen, size: 20.sp),
        ],
      ),
    );
  }
}
