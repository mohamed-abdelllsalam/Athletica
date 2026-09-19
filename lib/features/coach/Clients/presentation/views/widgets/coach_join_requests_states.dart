import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';

class CoachJoinRequestsLoadingView extends StatelessWidget {
  const CoachJoinRequestsLoadingView({super.key});
  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 7,
        itemBuilder: (_, _) => Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: SkeletonListTile(),
        ),
      ),
    );
  }
}

class CoachJoinRequestsErrorView extends StatelessWidget {
  const CoachJoinRequestsErrorView({
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
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.textSecondary,
              size: 48.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
