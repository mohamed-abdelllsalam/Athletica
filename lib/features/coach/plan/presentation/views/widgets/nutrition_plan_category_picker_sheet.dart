import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanCategoryPickerSheet extends StatelessWidget {
  const CoachNutritionPlanCategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selected,
  });

  final List<String> categories;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Select Category',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 14.h),
          ...categories.map(
            (cat) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                cat,
                style: AppTextStyles.medium14(context).copyWith(
                  color: cat == selected
                      ? AppColors.buttonColor
                      : AppColors.textPrimary,
                ),
              ),
              trailing: cat == selected
                  ? Icon(Icons.check, color: AppColors.buttonColor, size: 18.sp)
                  : null,
              onTap: () => Navigator.pop(context, cat),
            ),
          ),
        ],
      ),
    );
  }
}
