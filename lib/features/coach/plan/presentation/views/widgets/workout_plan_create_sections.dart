import 'workout_plan_category_picker_sheet.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlanCreateHeader extends StatelessWidget {
  const WorkoutPlanCreateHeader({
    super.key,
    required this.iconAsset,
    required this.nameController,
    required this.nameHasError,
    required this.dayCount,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  final String iconAsset;
  final TextEditingController nameController;
  final bool nameHasError;
  final int dayCount;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Name',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 4.h),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
                  decoration: InputDecoration(
                    hintText: 'Plan name',
                    hintStyle: AppTextStyles.bold24(
                      context,
                    ).copyWith(color: AppColors.textSecondary, fontSize: 20.sp),
                    errorText: nameHasError ? 'Required' : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      dayCount == 0 ? 'No days yet' : '$dayCount Days Split',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 8.w),
                    _CreateCategorySelector(
                      selected: selectedCategory,
                      categories: categories,
                      onChanged: onCategoryChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category selector pill (create mode) ─────────────────────────────────────

class _CreateCategorySelector extends StatelessWidget {
  const _CreateCategorySelector({
    required this.selected,
    required this.categories,
    required this.onChanged,
  });

  final String selected;
  final List<String> categories;
  final ValueChanged<String> onChanged;

  Color get _color => switch (selected) {
    'Strength' => const Color(0xFF7B4FE8),
    'Fat loss' => const Color(0xFF7B4FE8),
    'Boxing' => const Color(0xFFD4752A),
    'Mobility' => const Color(0xFF2E6DB4),
    'Vegan' => const Color(0xFF2E8A4A),
    _ => const Color(0xFFB22A4A),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pick = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (_) => CoachWorkoutPlanCategoryPickerSheet(
            categories: categories,
            selected: selected,
          ),
        );
        if (pick != null) onChanged(pick);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: AppTextStyles.semiBold10(context).copyWith(color: _color),
            ),
            SizedBox(width: 3.w),
            Icon(Icons.arrow_drop_down, color: _color, size: 14.sp),
          ],
        ),
      ),
    );
  }
}
