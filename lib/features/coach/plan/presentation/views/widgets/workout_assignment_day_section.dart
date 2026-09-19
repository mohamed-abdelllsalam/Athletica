import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

class CoachWorkoutAssignmentDaySection extends StatelessWidget {
  const CoachWorkoutAssignmentDaySection({
    super.key,
    required this.day,
    required this.exerciseCards,
  });

  final TemplateDayEntry day;
  final List<Widget> exerciseCards;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${day.dayNumber} — ${day.title}',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          if (day.note.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              day.note,
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 8.h),
          if (day.isRest || exerciseCards.isEmpty)
            Text(
              'Rest day — no exercises to customize.',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            )
          else
            ...exerciseCards,
        ],
      ),
    );
  }
}
