import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachExerciseSearchSummary extends StatelessWidget {
  const CoachExerciseSearchSummary({
    super.key,
    required this.summaryText,
    required this.onSubmit,
  });

  final String summaryText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Summary Of Training :',
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: 200.w,
                child: Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Submit',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
