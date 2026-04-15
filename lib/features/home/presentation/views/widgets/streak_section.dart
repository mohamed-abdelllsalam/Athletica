import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({super.key});

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<int> _dayNumbers = [3, 4, 5, 6, 7, 8, 9];

  static const List<int> _completedIndices = [0, 1, 2, 3];
  static const int _todayIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 16.h),
          _buildWeekRow(context),
          SizedBox(height: 12.h),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Your Streak',
              style: AppTextStyles.medium16(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        Text(
          'View calendar',
          style: AppTextStyles.medium13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWeekRow(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.streakBlue,
              size: 28.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              '4',
              style: AppTextStyles.extraBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 2.h),
            Text(
              'weeks',
              style: AppTextStyles.semiBold10(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_dayLabels.length, (index) {
              return _buildDayCircle(context, index);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCircle(BuildContext context, int index) {
    final bool isCompleted = _completedIndices.contains(index);
    final bool isToday = index == _todayIndex;

    Color circleColor;
    Color textColor;
    BoxBorder? border;

    if (isCompleted) {
      circleColor = AppColors.streakBlue;
      textColor = AppColors.textPrimary;
    } else if (isToday) {
      circleColor = Colors.transparent;
      textColor = AppColors.streakBlue;
      border = Border.all(color: AppColors.streakBlue, width: 2);
    } else {
      circleColor = AppColors.cardBackground;
      textColor = AppColors.textSecondary;
    }

    return Column(
      children: [
        Text(
          _dayLabels[index],
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            '${_dayNumbers[index]}',
            style: AppTextStyles.semiBold14(context).copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = index == 0;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 8.r : 6.r,
          height: isActive ? 8.r : 6.r,
          decoration: BoxDecoration(
            color: isActive ? AppColors.streakBlue : AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
