import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact exercise presentation shared by the client plan and today's workout.
class WorkoutExerciseRow extends StatelessWidget {
  const WorkoutExerciseRow({
    super.key,
    required this.order,
    required this.name,
    required this.thumbnail,
    this.primaryMuscle = '',
    this.prescription = '',
    this.rest = '',
    this.notes = '',
    this.completed = false,
    this.busy = false,
    this.onTap,
    this.onMediaTap,
    this.onCompletionChanged,
  });

  final int order;
  final String name;
  final Widget thumbnail;
  final String primaryMuscle;
  final String prescription;
  final String rest;
  final String notes;
  final bool completed;
  final bool busy;
  final VoidCallback? onTap;
  final VoidCallback? onMediaTap;
  final ValueChanged<bool>? onCompletionChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: completed ? 0.72 : 1,
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28.w,
                  child: Text(
                    order.toString().padLeft(2, '0'),
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: completed
                          ? AppColors.streakGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onMediaTap,
                  child: thumbnail,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold14(context).copyWith(
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (primaryMuscle.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          primaryMuscle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (prescription.isNotEmpty || rest.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 3.h,
                          children: [
                            if (prescription.isNotEmpty)
                              _Metadata(icon: Icons.repeat, text: prescription),
                            if (rest.isNotEmpty)
                              _Metadata(icon: Icons.timer_outlined, text: rest),
                          ],
                        ),
                      ],
                      if (notes.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text(
                          notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textTertiary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                if (busy)
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (onCompletionChanged != null)
                  Checkbox(
                    value: completed,
                    activeColor: AppColors.primaryPurple,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      if (value != null) onCompletionChanged!(value);
                    },
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 13.sp),
        SizedBox(width: 3.w),
        Text(
          text,
          style: AppTextStyles.meduim12(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
