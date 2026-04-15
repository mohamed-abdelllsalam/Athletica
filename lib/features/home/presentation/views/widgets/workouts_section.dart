import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutsSection extends StatelessWidget {
  const WorkoutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“Show up even on the days\nyou don\'t feel like it — that\'s\nwhere the real transformation\nbegins. I\'m not just training\nyour body, I\'m building your\ndiscipline',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.primaryBlue, height: 1.3),
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Text(
                'Type Of Training: ',
                style: AppTextStyles.medium16(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(width: 4.w),
              Text(
                'Day 1',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          const WorkoutCard(
            name: 'Bench Press',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
          const WorkoutCard(
            name: 'Incline Dumbbell Press',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
          const WorkoutCard(
            name: 'Cable Fly',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
          const WorkoutCard(
            name: 'Lat Pulldown',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
          const WorkoutCard(
            name: 'Row',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
          const WorkoutCard(
            name: 'Barbell Bent-Over Row',
            sets: 3,
            repsRange: '5-8',
            restRange: '1.5-2',
            bottomText: '1.5-2 Minutes of rest between sets',
          ),
        ],
      ),
    );
  }
}
