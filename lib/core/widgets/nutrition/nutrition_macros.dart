import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/nutrition_display_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionMacros extends StatelessWidget {
  const NutritionMacros({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fullLabels = false,
    this.compact = false,
  });
  final num protein, carbs, fat;
  final bool fullLabels, compact;
  @override
  Widget build(BuildContext context) {
    final stats = fullLabels
        ? [
            ('Carbs', carbs, AppColors.carbAccent),
            ('Protein', protein, AppColors.proteinAccent),
            ('Fat', fat, AppColors.fatAccent),
          ]
        : [
            ('P', protein, AppColors.proteinAccent),
            ('C', carbs, AppColors.carbAccent),
            ('F', fat, AppColors.fatAccent),
          ];
    if (compact) {
      return Wrap(
        spacing: 10.w,
        runSpacing: 4.h,
        children: [
          for (final stat in stats)
            Text(
              '${stat.$1} ${formatNutrition(stat.$2)}',
              style: AppTextStyles.meduim11(context).copyWith(color: stat.$3),
            ),
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 16.w,
                thickness: 1.w,
                color: AppColors.textTertiary.withValues(alpha: .4),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: fullLabels
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    stats[i].$1,
                    style: AppTextStyles.medium13(context).copyWith(
                      color: fullLabels ? AppColors.textPrimary : stats[i].$3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${formatNutrition(stats[i].$2)} g',
                    style: AppTextStyles.semiBold15(
                      context,
                    ).copyWith(color: stats[i].$3),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NutritionCalories extends StatelessWidget {
  const NutritionCalories({
    super.key,
    required this.calories,
    this.large = false,
  });
  final num calories;
  final bool large;
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: formatNutrition(calories),
          style:
              (large
                      ? AppTextStyles.extraBold45(context)
                      : AppTextStyles.extraBold30(context))
                  .copyWith(fontFamily: 'Inter', height: 1.2),
        ),
        TextSpan(text: ' kcal', style: AppTextStyles.medium16(context)),
      ],
    ),
    style: const TextStyle(color: AppColors.textPrimary),
  );
}
