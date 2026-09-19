import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanDetailLoading extends StatelessWidget {
  const CoachNutritionPlanDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        itemCount: 5,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, _) => SkeletonBox(height: 72.h, radius: 14.r),
      ),
    );
  }
}

class CoachNutritionPlanDetailError extends StatelessWidget {
  const CoachNutritionPlanDetailError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text(
              'Retry',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
