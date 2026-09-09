import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client workout history — `GET /workout/history` (no params).
/// `all_completed` → done; past non-rest incomplete → missed;
/// rest → rest.
class WorkoutHistoryView extends StatelessWidget {
  const WorkoutHistoryView({super.key});

  static const String routeName = 'workout-history';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutHistoryCubit>()..load(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  String _todayYmd() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Workout History',
                style: AppTextStyles.bold20(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<WorkoutHistoryCubit, WorkoutHistoryState>(
            builder: (context, state) => switch (state) {
              WorkoutHistoryInitial() ||
              WorkoutHistoryLoading() =>
                const Center(child: CircularProgressIndicator()),
              WorkoutHistoryError(:final message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () =>
                              context.read<WorkoutHistoryCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              WorkoutHistoryLoaded(:final days) => days.isEmpty
                  ? Center(
                      child: Text(
                        'No workout history yet.',
                        style: AppTextStyles.medium14(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<WorkoutHistoryCubit>().load(),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: days.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final day = days[index];
                          final bool completed = day.isCompletedUi;
                          final bool missed =
                              day.isMissed(_todayYmd());
                          final Color dot = day.isRest
                              ? AppColors.primaryBlue
                              : completed
                                  ? AppColors.streakGreen
                                  : missed
                                      ? Colors.redAccent
                                      : AppColors.textSecondary;
                          final String status = day.isRest
                              ? 'Rest'
                              : completed
                                  ? 'Completed'
                                  : missed
                                      ? 'Missed'
                                      : 'Pending';
                          return Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10.r,
                                  height: 10.r,
                                  decoration: BoxDecoration(
                                    color: dot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${day.date} • Day ${day.dayNumber} — ${day.title}',
                                        style:
                                            AppTextStyles.medium14(context)
                                                .copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${day.completedExercises}/${day.totalExercises} • $status',
                                        style:
                                            AppTextStyles.meduim12(context)
                                                .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (completed)
                                  Icon(Icons.check_circle,
                                      color: AppColors.streakGreen,
                                      size: 20.sp),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            },
          ),
        ),
      ],
    );
  }
}
