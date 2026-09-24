import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileCompletionHeading extends StatelessWidget {
  const CoachProfileCompletionHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: AppTextStyles.regular13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class CoachProfileCompletionActions extends StatelessWidget {
  const CoachProfileCompletionActions({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
