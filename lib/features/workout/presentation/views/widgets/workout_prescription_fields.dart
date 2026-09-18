import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutPrescriptionFields extends StatelessWidget {
  const WorkoutPrescriptionFields({
    super.key,
    required this.exercise,
    required this.name,
    required this.setsController,
    required this.repsController,
    required this.restController,
    required this.onSave,
  });

  final PlanExerciseEntry exercise;
  final String name;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController restController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${exercise.orderNumber}. $name',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                if (exercise.notes.isNotEmpty)
                  Text(
                    exercise.notes,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 52.w,
            child: TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Sets',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 52.w,
            child: TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Reps',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 52.w,
            child: TextField(
              controller: restController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Rest(s)',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Icon(Icons.check, color: AppColors.streakGreen, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
