import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SessionHistorySection extends StatelessWidget {
  const SessionHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session History',
          style: AppTextStyles.semiBold15(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        const _SessionItem(
          title: 'Session 1',
          subtitle: 'Strength Training',
          date: '15-1-2025',
        ),
        const _SessionItem(
          title: 'Session 2',
          subtitle: 'Cardio & Core',
          date: '20-2-2025',
        ),
        const _SessionItem(
          title: 'Session 3',
          subtitle: 'Full Body Workout',
          date: '29-3-2025',
        ),
      ],
    );
  }
}

class _SessionItem extends StatelessWidget {
  const _SessionItem({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  final String title;
  final String subtitle;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.medium13(context).copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: AppTextStyles.medium13(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
