import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_card.dart';
import 'package:athletica/features/client_coach/presentation/views/widgets/coach_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionStatus extends StatelessWidget {
  const NutritionStatus({
    super.key,
    required this.message,
    this.action,
    this.onAction,
  });
  final String message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => NutritionCard(
    child: Column(
      children: [
        Icon(
          Icons.restaurant_outlined,
          size: 32.sp,
          color: AppColors.primaryPurple,
        ),
        SizedBox(height: 12.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        if (action != null) ...[
          SizedBox(height: 8.h),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size(
                48.w.clamp(48, double.infinity),
                48.h.clamp(48, double.infinity),
              ),
              foregroundColor: AppColors.primaryPurple,
            ),
            child: Text(action!),
          ),
        ],
      ],
    ),
  );
}

class NutritionNoPlan extends StatelessWidget {
  const NutritionNoPlan({super.key, required this.onRefresh});
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) => NutritionStatus(
    message: "You don't have a nutrition plan yet.",
    action: 'Subscribe',
    onAction: () async {
      final sent = await showCoachCodeDialog(context);
      if (sent && context.mounted) onRefresh();
    },
  );
}

class NutritionLoading extends StatelessWidget {
  const NutritionLoading({super.key, this.plan = false});
  final bool plan;
  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      children: [
        SkeletonBox(height: 220.h, radius: 16.r),
        SizedBox(height: 16.h),
        if (plan) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 120.w, height: 56.h, radius: 12.r),
          ),
          SizedBox(height: 16.h),
        ],
        for (var i = 0; i < 3; i++) ...[
          SkeletonBox(height: 84.h, radius: 12.r),
          SizedBox(height: 10.h),
        ],
      ],
    ),
  );
}

class NutritionAppBar extends StatelessWidget {
  const NutritionAppBar({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(12.w, 10.h, 16.w, 10.h),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.w),
          Flexible(child: trailing!),
        ],
      ],
    ),
  );
}
