import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'workout_status_view.dart';

class TodayWorkoutRestView extends StatelessWidget {
  const TodayWorkoutRestView({super.key, required this.workout});
  final TodayWorkoutEntry workout;

  @override
  Widget build(BuildContext context) {
    return WorkoutStatusView(
      icon: Icons.bedtime_outlined,
      title: 'Day ${workout.dayNumber} — Rest Day',
      message: workout.note.trim().isNotEmpty
          ? workout.note.trim()
          : 'Recover today and come back ready for your next session.',
    );
  }
}

class TodayWorkoutEmptyExercises extends StatelessWidget {
  const TodayWorkoutEmptyExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
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

class TodayWorkoutLoadingView extends StatelessWidget {
  const TodayWorkoutLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          SkeletonBox(width: 220.w, height: 28.h, radius: 8.r),
          SizedBox(height: 18.h),
          SkeletonBox(height: 86.h, radius: 16.r),
          SizedBox(height: 18.h),
          for (var index = 0; index < 4; index++) ...[
            SkeletonBox(height: 92.h, radius: 14.r),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
