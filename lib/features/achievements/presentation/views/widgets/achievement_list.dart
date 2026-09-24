import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AchievementList extends StatelessWidget {
  const AchievementList({
    super.key,
    required this.achievements,
    required this.onOpen,
    this.onDelete,
    this.deletingId,
  });

  final List<CoachAchievement> achievements;
  final ValueChanged<CoachAchievement> onOpen;
  final ValueChanged<CoachAchievement>? onDelete;
  final String? deletingId;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'No certificates uploaded yet.',
          textAlign: TextAlign.center,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final achievement in achievements) ...[
          AchievementCard(
            achievement: achievement,
            onOpen: () => onOpen(achievement),
            onDelete: onDelete == null ? null : () => onDelete!(achievement),
            isDeleting: deletingId == achievement.id,
          ),
          if (achievement != achievements.last) SizedBox(height: 10.h),
        ],
      ],
    );
  }
}
