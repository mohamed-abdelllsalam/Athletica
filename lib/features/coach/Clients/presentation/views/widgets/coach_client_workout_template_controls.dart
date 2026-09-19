import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientWorkoutTemplateSearch extends StatelessWidget {
  const CoachClientWorkoutTemplateSearch({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TextField(
          onChanged: onChanged,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search plans...',
            hintStyle: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}

class CoachClientWorkoutTemplateError extends StatelessWidget {
  const CoachClientWorkoutTemplateError({
    super.key,
    required this.message,
    required this.showRetry,
    required this.onRetry,
  });
  final String message;
  final bool showRetry;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (showRetry) ...[
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
