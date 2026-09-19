import 'coach_client_streak_row.dart';
import 'coach_client_progress_chart.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientProgressSection extends StatelessWidget {
  const CoachClientProgressSection({
    super.key,
    required this.detail,
    required this.tabs,
    required this.selectedIndex,
    required this.dataPoints,
    required this.xLabels,
    required this.onTabSelected,
  });

  final ClientDetail detail;
  final List<String> tabs;
  final int selectedIndex;
  final List<double> dataPoints;
  final List<String> xLabels;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        CoachClientStreakRow(
          title: 'Nutrition Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFF5ED1A0),
          currentStreak: detail.nutritionStreak.current,
          lastDate: detail.nutritionStreak.lastDate,
        ),
        SizedBox(height: 10.h),
        CoachClientStreakRow(
          title: 'Workout Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFB76CFF),
          currentStreak: detail.workoutStreak.current,
          lastDate: detail.workoutStreak.lastDate,
          showLastDate: false,
        ),
        SizedBox(height: 16.h),
        _TabSelector(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: CoachClientProgressChart(
            dataPoints: dataPoints,
            xLabels: xLabels,
          ),
        ),
      ],
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                margin: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTextStyles.medium14(context).copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------- Line Chart ----------
