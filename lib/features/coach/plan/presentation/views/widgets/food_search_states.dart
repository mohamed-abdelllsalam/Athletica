import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';

class CoachFoodSearchLoading extends StatelessWidget {
  const CoachFoodSearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: 8,
        itemBuilder: (_, _) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SkeletonListTile(leadingSize: 40.r, trailingSize: 28.r),
          ),
        ),
      ),
    );
  }
}

class CoachFoodSearchError extends StatelessWidget {
  const CoachFoodSearchError({
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
