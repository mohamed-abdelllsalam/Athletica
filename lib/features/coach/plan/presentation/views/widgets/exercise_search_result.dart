import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';

class CoachExerciseSearchResult extends StatelessWidget {
  const CoachExerciseSearchResult({
    super.key,
    required this.exercise,
    required this.selected,
    required this.onPlay,
    required this.onToggle,
  });
  final WorkoutExerciseEntry exercise;
  final bool selected;
  final VoidCallback onPlay;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlay,
            child: ExerciseThumbnail(
              size: 72,
              thumbnailUrl: exercise.thumbnailUrlMale,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buildBilingualLabel(
                    primary: exercise.nameEn,
                    arabic: exercise.nameAr,
                    english: exercise.nameEn,
                  ),
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                if (exercise.primaryMuscle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    exercise.primaryMuscle,
                    style: AppTextStyles.meduim11(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              selected ? Icons.bookmark : Icons.bookmark_border,
              color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}
