import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileBioField extends StatelessWidget {
  const CoachProfileBioField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText:
            'Hook your future clients, show them what makes you different.',
        hintStyle: AppTextStyles.regular13(
          context,
        ).copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

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
  const CoachProfileCompletionActions({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: Column(
        children: [
          SizedBox(
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
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
