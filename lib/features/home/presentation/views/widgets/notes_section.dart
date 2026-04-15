import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesSection extends StatelessWidget {
  const NotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: AppTextStyles.bold20(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.cardBackgroundLight,
                width: 0.5,
              ),
            ),
            child: TextField(
              style: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Write your note ..!',
                hintStyle: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
              ),
              maxLines: 2,
              minLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
