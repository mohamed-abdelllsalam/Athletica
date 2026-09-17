import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NutritionPlanHeader extends StatelessWidget {
  const NutritionPlanHeader({
    super.key,
    required this.plan,
    required this.isCreateMode,
    required this.iconAsset,
    required this.nameController,
    required this.nameHasError,
    required this.calories,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final NutritionPlan plan;
  final bool isCreateMode;
  final String iconAsset;
  final TextEditingController nameController;
  final bool nameHasError;
  final int calories;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCreateMode) ...[
                  Text(
                    'Plan Name',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 4.h),
                  _EditableNameField(
                    controller: nameController,
                    hasError: nameHasError,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: AppTextStyles.bold24(context).copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _PlanHeaderAction(
                        icon: Icons.edit_outlined,
                        color: AppColors.primaryBlue,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 8.w),
                      _PlanHeaderAction(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFFF5252),
                        onTap: onDelete,
                      ),
                    ],
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
                      '$calories calories',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 8.w),
                    if (isCreateMode)
                      _CategorySelector(
                        selected: selectedCategory,
                        categories: categories,
                        onChanged: onCategoryChanged,
                      )
                    else
                      _CategoryBadge(category: plan.category),
                  ],
                ),
                if (!isCreateMode) ...[
                  SizedBox(height: 4.h),
                  _PlanMetadataRow(
                    icon: Icons.access_time,
                    text: plan.updatedAgo,
                  ),
                  SizedBox(height: 4.h),
                  _PlanMetadataRow(
                    icon: Icons.person_outline,
                    text: 'Used by ${plan.clientCount} clients',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
    'Fat loss' => const Color(0xFF7B4FE8),
    'Muscle Gain' => const Color(0xFF3D6BC2),
    'Vegan' => const Color(0xFF2E8A4A),
    'Custom' => const Color(0xFFB22A4A),
    _ => AppColors.primaryBlue,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        category,
        style: AppTextStyles.semiBold10(context).copyWith(color: _color),
      ),
    );
  }
}

class _PlanHeaderAction extends StatelessWidget {
  const _PlanHeaderAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

class _PlanMetadataRow extends StatelessWidget {
  const _PlanMetadataRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 12.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EditableNameField extends StatelessWidget {
  const _EditableNameField({required this.controller, required this.hasError});

  final TextEditingController controller;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: AppTextStyles.bold24(
        context,
      ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
      decoration: InputDecoration(
        hintText: 'Plan name',
        hintStyle: AppTextStyles.bold24(
          context,
        ).copyWith(color: AppColors.textSecondary, fontSize: 20.sp),
        errorText: hasError ? 'Required' : null,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Category selector pill (create mode) ─────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.categories,
    required this.onChanged,
  });

  final String selected;
  final List<String> categories;
  final ValueChanged<String> onChanged;

  Color get _color => switch (selected) {
    'Fat loss' => const Color(0xFF7B4FE8),
    'Muscle Gain' => const Color(0xFF3D6BC2),
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
          builder: (_) =>
              _CategoryPickerSheet(categories: categories, selected: selected),
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

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
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

// ── Overview Tab ─────────────────────────────────────────────────────────────
