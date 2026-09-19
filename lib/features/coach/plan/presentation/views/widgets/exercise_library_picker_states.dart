import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachExercisePickerError extends StatelessWidget {
  const CoachExercisePickerError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class CoachExercisePickerEmpty extends StatelessWidget {
  const CoachExercisePickerEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No exercises found',
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class CoachExercisePickerAction extends StatelessWidget {
  const CoachExercisePickerAction({
    super.key,
    required this.newCount,
    required this.onSubmit,
  });
  final int newCount;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: newCount > 0 ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              disabledBackgroundColor: AppColors.buttonColor.withValues(
                alpha: 0.35,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              newCount == 0
                  ? 'Add Exercises'
                  : 'Add $newCount Exercise${newCount == 1 ? '' : 's'}',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
