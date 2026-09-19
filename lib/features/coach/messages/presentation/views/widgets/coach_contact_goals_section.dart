import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachContactGoalsSection extends StatelessWidget {
  const CoachContactGoalsSection({super.key, required this.contact});
  final ChatContact contact;
  static IconData _goalIcon(String goal) {
    if (goal.toLowerCase().contains('weight')) {
      return Icons.monitor_weight_outlined;
    } else if (goal.toLowerCase().contains('muscle')) {
      return Icons.fitness_center;
    } else if (goal.toLowerCase().contains('energy')) {
      return Icons.bolt;
    }
    return Icons.calendar_today_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 14.h),
        ...contact.goals.map(
          (goal) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Icon(
                  _goalIcon(goal),
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  goal,
                  style: AppTextStyles.medium15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
