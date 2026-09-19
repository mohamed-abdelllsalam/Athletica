import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutPlansError extends StatelessWidget {
  const CoachWorkoutPlansError({
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

class CoachWorkoutPlansEmpty extends StatelessWidget {
  const CoachWorkoutPlansEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No programs found',
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
