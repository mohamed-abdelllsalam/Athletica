import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealCard extends StatefulWidget {
  const MealCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final String emoji;
  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final double fat;

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isDone = false;

  static const _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final Color cardBg = _isDone
        ? const Color(0xFF2E2E2E)
        : AppColors.cardBackground;
    final Color borderColor = _isDone
        ? const Color(0xFF3A3A3A)
        : AppColors.cardBackgroundLight;
    final Color nameColor = _isDone
        ? AppColors.textTertiary
        : AppColors.textPrimary;
    final Color detailColor = _isDone
        ? AppColors.textTertiary
        : AppColors.textSecondary;
    final Color iconColor = _isDone
        ? AppColors.textTertiary
        : AppColors.primaryPurple;

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
            colorFilter: _isDone
                ? const ColorFilter.matrix(_grayscaleMatrix)
                : const ColorFilter.mode(Colors.transparent, BlendMode.color),
            child: Text(widget.emoji, style: TextStyle(fontSize: 32.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: nameColor),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Calories: ${widget.calories} kcal',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Carbohydrates: ${widget.carbs} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Protein: ${widget.protein} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Fat: ${widget.fat} g',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: detailColor),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isDone = !_isDone),
            child: Icon(Icons.fingerprint, size: 32.sp, color: iconColor),
          ),
        ],
      ),
    );
  }
}
