import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientAssignedPlansSection extends StatelessWidget {
  const CoachClientAssignedPlansSection({
    super.key,
    required this.nutritionPlan,
    required this.workoutTitle,
    required this.workoutSubtitle,
    required this.onDeactivateNutrition,
    required this.onDeactivateWorkout,
    required this.onAssignNutrition,
    required this.onAssignWorkout,
  });

  final NutritionPlanSummary? nutritionPlan;
  final String? workoutTitle;
  final String workoutSubtitle;
  final VoidCallback? onDeactivateNutrition;
  final VoidCallback? onDeactivateWorkout;
  final VoidCallback onAssignNutrition;
  final VoidCallback onAssignWorkout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Plan',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        if (nutritionPlan case final plan?)
          _PlanCard(
            iconData: Icons.receipt_long,
            iconBgColor: AppColors.streakGreen,
            title: plan.title,
            subtitle: plan.description ?? 'Nutrition Plan',
            isActive: plan.isActive,
            onDelete: onDeactivateNutrition,
          )
        else
          _AssignPlanCard(
            label: 'Assign Nutrition Plan',
            onPressed: onAssignNutrition,
          ),
        SizedBox(height: 10.h),
        if (workoutTitle case final title?)
          _PlanCard(
            iconData: Icons.fitness_center,
            iconBgColor: AppColors.primaryBlue,
            title: title,
            subtitle: workoutSubtitle,
            onDelete: onDeactivateWorkout,
          )
        else
          _AssignPlanCard(
            label: 'Assign Workout Plan',
            onPressed: onAssignWorkout,
          ),
      ],
    );
  }
}

// ---------- Plan Card ----------

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.iconData,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.isActive = true,
    this.onDelete,
  });

  final IconData iconData;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: isActive
            ? null
            : Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(iconData, color: iconBgColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- Assign Plan Card ----------

class _AssignPlanCard extends StatelessWidget {
  const _AssignPlanCard({required this.onPressed, this.label = 'Assign Plan'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryBlue,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
