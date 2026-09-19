import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/food_search_components.dart';

class CoachFoodSearchHeader extends StatelessWidget {
  const CoachFoodSearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onBack,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          FoodSearchIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          FoodSearchIconButton(icon: Icons.delete_outline, onTap: onClear),
        ],
      ),
    );
  }
}
