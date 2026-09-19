import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachLegacyAssessmentItem extends StatelessWidget {
  const CoachLegacyAssessmentItem({
    super.key,
    required this.number,
    required this.question,
    required this.answer,
  });

  final int number;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q$number',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.primaryPurple),
        ),
        SizedBox(height: 8.h),
        Text(
          question,
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary, height: 1.25),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.textPrimary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
