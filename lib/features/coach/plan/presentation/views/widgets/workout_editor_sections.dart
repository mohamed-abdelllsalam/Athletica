import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutEditorDayCounter extends StatelessWidget {
  const CoachWorkoutEditorDayCounter({
    super.key,
    required this.day,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int day;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            'Day',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: Colors.white),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Text(
            '$day',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: Colors.white),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: onIncrement,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CoachWorkoutEditorSectionLabel extends StatelessWidget {
  const CoachWorkoutEditorSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.semiBold14(
        context,
      ).copyWith(color: AppColors.textPrimary),
    );
  }
}

class CoachWorkoutEditorAddExerciseButton extends StatelessWidget {
  const CoachWorkoutEditorAddExerciseButton({
    super.key,
    required this.onTap,
    this.addedCount = 0,
  });

  final VoidCallback onTap;
  final int addedCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.r,
              height: 22.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primaryBlue, size: 16.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              addedCount > 0
                  ? '+ Add An Exercise ($addedCount)'
                  : '+ Add An Exercise',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
