import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachVideoUploadLoading extends StatelessWidget {
  const CoachVideoUploadLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }
}

class CoachVideoUploadError extends StatelessWidget {
  const CoachVideoUploadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSecondary, width: 1.5),
              ),
              child: Icon(
                Icons.priority_high_rounded,
                color: AppColors.textSecondary,
                size: 22.r,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Try again',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.close, color: Colors.redAccent, size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Upload failed. Please try again or check your internet connection',
                style: AppTextStyles.regular13(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CoachVideoUploadSuccess extends StatelessWidget {
  const CoachVideoUploadSuccess({
    super.key,
    required this.videoPath,
    required this.onReplace,
  });

  final String videoPath;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: double.infinity,
                height: 200.h,
                color: AppColors.cardBackground,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textPrimary,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onReplace,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Replace Video',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
