import 'package:athletica/core/utils/streak_calendar.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StreakRow extends StatelessWidget {
  const StreakRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.currentStreak,
    required this.lastDate,
    this.showLastDate = true,
    this.statusesByDate = const {},
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int currentStreak;
  final String? lastDate;
  final bool showLastDate;
  final Map<String, StreakDayStatus> statusesByDate;

  @override
  Widget build(BuildContext context) {
    final days = lastDate == null
        ? <StreakCalendarDay>[]
        : buildStreakCalendar(to: lastDate!, statusesByDate: statusesByDate);

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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: iconColor, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                          style: AppTextStyles.semiBold14(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(days.length, (index) {
                    final day = days[index];
                    final status = day.status;
                    final isDone = status == StreakDayStatus.completed;
                    final isRest = status == StreakDayStatus.rest;
                    return Tooltip(
                      message: '${day.date}: ${status?.name ?? 'Unavailable'}',
                      child: Column(
                        children: [
                          Container(
                            width: 24.r,
                            height: 24.r,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? iconColor.withValues(alpha: 0.18)
                                  : isRest
                                  ? AppColors.streakBlue.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isDone
                                    ? iconColor
                                    : isRest
                                    ? AppColors.streakBlue
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.65,
                                      ),
                                width: 1.3,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: isRest
                                ? Text(
                                    'R',
                                    style: AppTextStyles.semiBold14(
                                      context,
                                    ).copyWith(color: AppColors.streakBlue),
                                  )
                                : Icon(
                                    isDone
                                        ? Icons.check_rounded
                                        : status == null
                                        ? Icons.remove_rounded
                                        : Icons.close_rounded,
                                    size: 14.sp,
                                    color: isDone
                                        ? iconColor
                                        : isRest
                                        ? AppColors.streakBlue
                                        : AppColors.textSecondary,
                                  ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            day.label,
                            style: AppTextStyles.meduim11(context).copyWith(
                              color: day.isToday
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
