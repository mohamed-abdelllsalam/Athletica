import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutAssignmentExerciseCard extends StatelessWidget {
  const CoachWorkoutAssignmentExerciseCard({
    super.key,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  final String name;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController rest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _LoadField(label: 'Sets', hint: '4', controller: sets),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LoadField(label: 'Reps', hint: '10', controller: reps),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LoadField(
                  label: 'Rest (s)',
                  hint: '90',
                  controller: rest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadField extends StatelessWidget {
  const _LoadField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
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
              ).copyWith(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
