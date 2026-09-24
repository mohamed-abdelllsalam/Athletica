import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onOpen,
    this.onDelete,
    this.isDeleting = false,
  });

  final CoachAchievement achievement;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final fileName = achievement.fileName?.trim();
    final subtitle = [
      if (fileName != null && fileName.isNotEmpty) fileName else 'PDF document',
      _formatDate(achievement.createdAt),
    ].join(' • ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpen,
            tooltip: 'Open PDF',
            icon: const Icon(Icons.open_in_new, color: AppColors.primaryBlue),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: isDeleting ? null : onDelete,
              tooltip: 'Delete certificate',
              icon: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
