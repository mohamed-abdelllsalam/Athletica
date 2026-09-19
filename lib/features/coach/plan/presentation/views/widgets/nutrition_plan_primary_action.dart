import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanPrimaryAction extends StatelessWidget {
  const CoachNutritionPlanPrimaryAction({
    super.key,
    required this.isCreateMode,
    required this.onSave,
    required this.onAssign,
  });
  final bool isCreateMode;
  final VoidCallback onSave;
  final VoidCallback onAssign;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: isCreateMode
            ? ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save Plan',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              )
            : ElevatedButton.icon(
                onPressed: onAssign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 18.sp,
                ),
                label: Text(
                  'Assign to client',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
