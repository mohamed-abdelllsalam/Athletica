import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachEditProfileSaveAction extends StatelessWidget {
  const CoachEditProfileSaveAction({
    super.key,
    required this.hasChanges,
    required this.isUpdating,
    required this.onSave,
  });

  final bool hasChanges;
  final bool isUpdating;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      color: AppColors.primaryAppColor,
      child: SizedBox(
        height: 52.h,
        child: ElevatedButton(
          onPressed: (hasChanges && !isUpdating) ? onSave : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasChanges
                ? AppColors.primaryBlue
                : AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save Change',
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
        ),
      ),
    );
  }
}
