import 'package:athletica/core/widgets/streak_row.dart';
import 'package:athletica/core/widgets/progress_history_unavailable.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/streak/presentation/cubits/streak_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientProgressSection extends StatelessWidget {
  const CoachClientProgressSection({
    super.key,
    required this.detail,
    required this.streakState,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final ClientDetail detail;
  final StreakState streakState;
  final List<String> tabs;
  final int selectedIndex;
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
        if (streakState is StreakLoading)
          const Center(child: CircularProgressIndicator())
        else if (streakState is StreakError)
          Text((streakState as StreakError).message)
        else if (streakState is StreakEmpty)
          const Text('No streak activity yet')
        else if (streakState is StreakLoaded) ...[
          if ((streakState as StreakLoaded).data.nutritionSummary == null)
            Text(
              (streakState as StreakLoaded).data.nutritionError ??
                  'Nutrition streak unavailable',
            )
          else
            StreakRow(
              title: 'Nutrition Streak',
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFF5ED1A0),
              currentStreak: (streakState as StreakLoaded)
                  .data
                  .nutritionSummary!
                  .currentStreak,
              lastDate: (streakState as StreakLoaded).data.nutritionSummary!.to,
              statusesByDate: {
                for (final day
                    in (streakState as StreakLoaded).data.nutritionDays)
                  day.date: day.status,
              },
            ),
          SizedBox(height: 10.h),
          if ((streakState as StreakLoaded).data.workoutSummary == null)
            Text(
              (streakState as StreakLoaded).data.workoutError ??
                  'Workout streak unavailable',
            )
          else
            StreakRow(
              title: 'Workout Streak',
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFB76CFF),
              currentStreak: (streakState as StreakLoaded)
                  .data
                  .workoutSummary!
                  .currentStreak,
              lastDate: (streakState as StreakLoaded).data.workoutSummary!.to,
              showLastDate: false,
              statusesByDate: {
                for (final day
                    in (streakState as StreakLoaded).data.workoutDays)
                  day.date: day.status,
              },
            ),
        ],
        SizedBox(height: 16.h),
        _TabSelector(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
        ),
        SizedBox(height: 16.h),
        SizedBox(height: 200.h, child: const ProgressHistoryUnavailable()),
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
