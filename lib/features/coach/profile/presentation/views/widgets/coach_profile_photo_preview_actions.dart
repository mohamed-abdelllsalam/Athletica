import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfilePhotoPreviewActions extends StatelessWidget {
  const CoachProfilePhotoPreviewActions({
    super.key,
    required this.onSave,
    required this.onCancel,
  });
  final VoidCallback onSave;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Preview',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Save Photo',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textTertiary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
