import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Exercises tab ─────────────────────────────────────────────────────────────

class WorkoutDayExercisesTab extends StatelessWidget {
  const WorkoutDayExercisesTab({
    super.key,
    required this.searchController,
    required this.exercises,
    required this.allExercises,
    required this.query,
    required this.onQueryChanged,
    required this.onDelete,
    required this.onSave,
    required this.onOpenPicker,
    required this.onClearAll,
  });

  final TextEditingController searchController;
  final List<ProgramExercise> exercises;
  final List<ProgramExercise> allExercises;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProgramExercise> onDelete;
  final VoidCallback onSave;
  final VoidCallback onOpenPicker;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onQueryChanged,
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Trash icon — clears all exercises after confirm
              GestureDetector(
                onTap: onClearAll,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.delete_sweep_outlined,
                    color: allExercises.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
            itemCount: exercises.isEmpty && query.isNotEmpty
                ? 1
                : exercises.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              // Empty search state
              if (exercises.isEmpty && query.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Text(
                      'No exercises found',
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              // + Add Exercise tile (last item)
              if (index == exercises.length) {
                return _AddExerciseTile(onTap: onOpenPicker);
              }
              final exercise = exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                onDelete: () => onDelete(exercise),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Save Changes',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Add Exercise dashed tile ──────────────────────────────────────────────────

class _AddExerciseTile extends StatelessWidget {
  const _AddExerciseTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.buttonColor.withValues(alpha: 0.5),
            width: 1.5,
            // Dashed via custom painter below
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.buttonColor,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Add Exercise',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.buttonColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onDelete});

  final ProgramExercise exercise;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showExerciseVideoDialog(
              context,
              title: exercise.displayName,
              videoUrl: resolveExerciseVideoUrl(
                maleUrl: exercise.videoUrlMale,
                femaleUrl: exercise.videoUrlFemale,
              ),
              thumbnailUrl: exercise.thumbnailUrl,
            ),
            child: ExerciseThumbnail(
              size: 64,
              thumbnailUrl: exercise.thumbnailUrl,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              exercise.displayName,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
