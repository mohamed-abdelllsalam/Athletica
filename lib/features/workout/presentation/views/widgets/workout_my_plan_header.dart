import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutMyPlanHeader extends StatelessWidget {
  const WorkoutMyPlanHeader({
    super.key,
    required this.plan,
    required this.dayCount,
  });
  final WorkoutPlanEntry plan;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Training Plan',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.primaryPurple),
          ),
          SizedBox(height: 5.h),
          Text(
            plan.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 5.h),
          Text(
            '$dayCount ${dayCount == 1 ? 'day' : 'days'} per cycle',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          if (plan.description.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              plan.description.trim(),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
