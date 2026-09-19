import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanDailyTargets extends StatelessWidget {
  const CoachNutritionPlanDailyTargets({
    super.key,
    required this.plan,
    required this.isCreateMode,
    required this.caloriesController,
    required this.proteinController,
    required this.fatController,
    required this.carbsController,
    required this.onMacrosChanged,
  });
  final NutritionPlan plan;
  final bool isCreateMode;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController fatController;
  final TextEditingController carbsController;
  final VoidCallback onMacrosChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily targets',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isCreateMode) ...[
                _MacroInput(
                  controller: caloriesController,
                  label: 'Calories',
                  color: AppColors.primaryBlue,
                  onChanged: (_) => onMacrosChanged(),
                ),
                _MacroInput(
                  controller: proteinController,
                  label: 'Protein',
                  color: const Color(0xFF4CAF50),
                  onChanged: (_) => onMacrosChanged(),
                  suffix: 'g',
                ),
                _MacroInput(
                  controller: fatController,
                  label: 'Fat',
                  color: const Color(0xFFFFB300),
                  onChanged: (_) => onMacrosChanged(),
                  suffix: 'g',
                ),
                _MacroInput(
                  controller: carbsController,
                  label: 'Carbs',
                  color: const Color(0xFF42A5F5),
                  onChanged: (_) => onMacrosChanged(),
                  suffix: 'g',
                ),
              ] else ...[
                _MacroStat(
                  value: '${plan.calories}',
                  label: 'Calories',
                  color: AppColors.primaryBlue,
                ),
                _MacroStat(
                  value: '${plan.proteinGrams}g',
                  label: 'Protein',
                  color: const Color(0xFF4CAF50),
                ),
                _MacroStat(
                  value: '${plan.fatGrams}g',
                  label: 'Fat',
                  color: const Color(0xFFFFB300),
                ),
                _MacroStat(
                  value: '${plan.carbsGrams}g',
                  label: 'Carbs',
                  color: const Color(0xFF42A5F5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: color, fontSize: 18.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MacroInput extends StatelessWidget {
  const _MacroInput({
    required this.controller,
    required this.label,
    required this.color,
    required this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final ValueChanged<String> onChanged;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: color, fontSize: 18.sp),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.bold24(
                context,
              ).copyWith(color: color.withValues(alpha: 0.4), fontSize: 18.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          suffix == null ? label : '$label ($suffix)',
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
