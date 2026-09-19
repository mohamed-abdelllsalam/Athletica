import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoachPlanTypeCard extends StatelessWidget {
  const CoachPlanTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stat1Label,
    required this.stat1Value,
    required this.stat2Label,
    required this.stat2Value,
    required this.iconAsset,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String stat1Label;
  final String stat1Value;
  final String stat2Label;
  final String stat2Value;
  final String iconAsset;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
                ),
                const Spacer(),
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: Colors.white, fontSize: 22.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _StatItem(label: stat1Label, value: stat1Value),
                SizedBox(width: 36.w),
                _StatItem(label: stat2Label, value: stat2Value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        value == '--'
            ? AppShimmer(
                child: SkeletonBox(width: 34.w, height: 22.h, radius: 6.r),
              )
            : Text(
                value,
                style: AppTextStyles.bold24(context).copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: Colors.white.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}
