import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.mealType,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.completed,
    this.busy = false,
    this.onToggle,
  });

  final String mealType;
  final String name;
  final num calories;
  final num carbs;
  final num protein;
  final num fat;
  final bool completed;
  final bool busy;
  final VoidCallback? onToggle;

  static const _emojiByType = {
    'breakfast': '🥣',
    'lunch': '🥩',
    'snack': '🥜',
    'snacks': '🥜',
    'dinner': '🍳',
  };

  static const _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  String get _emoji => _emojiByType[mealType.toLowerCase()] ?? '🍽️';

  String _format(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final Color cardBg = completed
        ? const Color(0xFF2E2E2E)
        : AppColors.cardBackground;
    final Color borderColor = completed
        ? const Color(0xFF3A3A3A)
        : AppColors.cardBackgroundLight;
    final Color nameColor =
        completed ? AppColors.textTertiary : AppColors.textPrimary;
    final Color detailColor =
        completed ? AppColors.textTertiary : AppColors.textSecondary;
    final Color iconColor =
        completed ? AppColors.streakGreen : AppColors.primaryPurple;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: completed
                ? const ColorFilter.matrix(_grayscaleMatrix)
                : const ColorFilter.mode(Colors.transparent, BlendMode.color),
            child: Text(_emoji, style: TextStyle(fontSize: 32.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: nameColor),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Calories: ${_format(calories)} kcal',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Carbohydrates: ${_format(carbs)} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Protein: ${_format(protein)} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Fat: ${_format(fat)} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onToggle,
            child: busy
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.fingerprint,
                    size: 32.sp,
                    color: iconColor,
                  ),
          ),
        ],
      ),
    );
  }
}
