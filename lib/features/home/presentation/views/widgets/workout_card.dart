import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.name,
    required this.sets,
    required this.repsRange,
    required this.restRange,
    required this.bottomText,
    this.onRepsTap,
    this.onPlayTap,
    this.thumbnailUrl = '',
  });

  final String name;
  final int sets;
  final String repsRange;
  final String restRange;
  final String bottomText;
  final VoidCallback? onRepsTap;
  final VoidCallback? onPlayTap;

  /// Backend thumbnail; empty keeps the play-icon placeholder.
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBackgroundLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onPlayTap,
                child: Container(
                  width: 90.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: thumbnailUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primaryBlue.withValues(alpha: 0.8),
                            size: 32.sp,
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.8,
                                  ),
                                  size: 32.sp,
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 28.sp,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• $name',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: [
                        _Badge(text: 'Sets:$sets'),
                        _Badge(text: 'Reps:$repsRange'),
                        _Badge(text: 'Rest: $restRange'),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRepsTap,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Reps',
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            bottomText,
            style: AppTextStyles.semiBold10(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.meduim11(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
