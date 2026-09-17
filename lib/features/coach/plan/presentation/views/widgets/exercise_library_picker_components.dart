import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExercisePickerHeader extends StatelessWidget {
  const ExercisePickerHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Exercise Library',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class ExercisePickerSearchField extends StatelessWidget {
  const ExercisePickerSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises',
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
    );
  }
}

class ExercisePickerResultCard extends StatelessWidget {
  const ExercisePickerResultCard({
    super.key,
    required this.name,
    required this.muscle,
    this.thumbnailUrl = '',
    required this.isSelected,
    this.alreadyAdded = false,
    required this.onTap,
    this.onPlay,
  });

  final String name;
  final String muscle;
  final String thumbnailUrl;
  final bool isSelected;

  /// Already in this day: dimmed with an "Added" mark, tap does nothing.
  final bool alreadyAdded;
  final VoidCallback onTap;

  /// Plays the exercise demo video; null leaves the thumbnail static.
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alreadyAdded ? null : onTap,
      child: Opacity(
        opacity: alreadyAdded ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: alreadyAdded
                ? Border.all(
                    color: const Color(0xFF2E8A4A).withValues(alpha: 0.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                child: ExerciseThumbnail(size: 64, thumbnailUrl: thumbnailUrl),
              ),
              SizedBox(width: 12.w),
              Expanded(
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
                    if (muscle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        muscle,
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    if (alreadyAdded) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Added',
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: const Color(0xFF2E8A4A)),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (alreadyAdded)
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF2E8A4A),
                  size: 22.sp,
                )
              else
                Icon(
                  isSelected ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: isSelected
                      ? AppColors.buttonColor
                      : AppColors.textSecondary,
                  size: 22.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExercisePickerMuscleFilterRail extends StatelessWidget {
  const ExercisePickerMuscleFilterRail({
    super.key,
    required this.muscles,
    required this.selectedMuscle,
    required this.onSelect,
  });

  final List<String> muscles;
  final String selectedMuscle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(4.w, 0, 8.w, 100.h),
        physics: const BouncingScrollPhysics(),
        itemCount: muscles.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final muscle = muscles[index];
          final isSelected = muscle == selectedMuscle;
          return GestureDetector(
            onTap: () => onSelect(muscle),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonColor
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  muscle,
                  style: AppTextStyles.meduim11(context).copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
