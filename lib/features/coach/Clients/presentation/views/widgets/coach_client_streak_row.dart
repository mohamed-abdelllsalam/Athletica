import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientStreakRow extends StatelessWidget {
  const CoachClientStreakRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.currentStreak,
    required this.lastDate,
    this.showLastDate = true,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int currentStreak;
  final String? lastDate;
  final bool showLastDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      if (i == 6) return 'Today';
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    if (showLastDate && lastDate != null)
                      Text(
                        'Last: $lastDate',
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(days.length, (index) {
                    final isDone = index < currentStreak;
                    return Column(
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: isDone
                                ? iconColor.withValues(alpha: 0.18)
                                : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? iconColor
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.65,
                                    ),
                              width: 1.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : Icons.close_rounded,
                            size: 14.sp,
                            color: isDone ? iconColor : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          days[index],
                          style: AppTextStyles.meduim11(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
