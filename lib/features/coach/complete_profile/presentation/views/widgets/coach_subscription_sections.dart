import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachSubscriptionTabs extends StatelessWidget {
  const CoachSubscriptionTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.textPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: active
                        ? AppColors.primaryAppColor
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class CoachSubscriptionPricingCard extends StatelessWidget {
  const CoachSubscriptionPricingCard({
    super.key,
    required this.label,
    required this.price,
    required this.period,
    required this.accentColor,
  });

  final String label;
  final String price;
  final String period;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'EGP ',
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          price,
                          style: AppTextStyles.bold24(context).copyWith(
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          '\$  ',
                          style: AppTextStyles.bold24(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          period,
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
