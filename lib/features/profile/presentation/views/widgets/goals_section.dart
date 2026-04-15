import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  static const List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Improved Energy',
    'Consistent Workout Routine',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals:',
          style: AppTextStyles.semiBold15(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(
          _goals.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              _goals[index],
              style: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
