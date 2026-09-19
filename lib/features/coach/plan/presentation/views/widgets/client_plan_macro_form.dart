import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientPlanMacroForm extends StatelessWidget {
  const CoachClientPlanMacroForm({
    super.key,
    required this.fatController,
    required this.proteinController,
    required this.carbController,
  });
  final TextEditingController fatController;
  final TextEditingController proteinController;
  final TextEditingController carbController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fat',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        _MacroField(controller: fatController, hint: 'Type Fat'),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protein',
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  _MacroField(
                    controller: proteinController,
                    hint: 'Type Protein',
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carb',
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  _MacroField(controller: carbController, hint: 'Type Carb'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
