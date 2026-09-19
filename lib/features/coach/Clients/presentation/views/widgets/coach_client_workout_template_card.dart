import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athletica/features/workout/domain/entities/workout_template.dart';

class CoachClientWorkoutTemplateCard extends StatelessWidget {
  const CoachClientWorkoutTemplateCard({
    super.key,
    required this.item,
    required this.isLoading,
    required this.onTap,
  });
  final WorkoutTemplateEntry item;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.surfaceDark, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.fitness_center,
                      color: AppColors.primaryBlue,
                      size: 20.sp,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${item.dayCount} days • ${item.exerciseCount} exercises',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
