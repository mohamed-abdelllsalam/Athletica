import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client "My Plan" — `GET /workout/my/plans` + details.
/// Null plan shows the empty state.
class WorkoutMyPlanView extends StatelessWidget {
  const WorkoutMyPlanView({super.key});

  static const String routeName = 'workout-my-plan';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutMyPlanCubit>()..loadActive(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

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
                'My Workout Plan',
                style: AppTextStyles.bold20(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<WorkoutMyPlanCubit, WorkoutMyPlanState>(
            builder: (context, state) => switch (state) {
              WorkoutMyPlanInitial() || WorkoutMyPlanLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              WorkoutMyPlanError(:final message) => Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () =>
                            context.read<WorkoutMyPlanCubit>().loadActive(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              WorkoutMyPlanLoaded(:final plan) =>
                plan == null
                    ? _EmptyView(
                        onRefresh: () =>
                            context.read<WorkoutMyPlanCubit>().loadActive(),
                      )
                    : _PlanContent(plan: plan),
              WorkoutMyPlanDetailLoaded(:final plan) => _PlanContent(
                plan: plan,
              ),
            },
          ),
        ),
      ],
    );
  }
}

/// Formats rest seconds as `90s` / `1:30` (DOC_6 §1.5); null → "—".
String _formatRest(int? seconds) {
  if (seconds == null) return '—';
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class _PlanContent extends StatefulWidget {
  const _PlanContent({required this.plan});

  final WorkoutPlanEntry plan;

  @override
  State<_PlanContent> createState() => _PlanContentState();
}

class _PlanContentState extends State<_PlanContent> {
  /// Only one day expanded at a time — the plan reads as a day list
  /// the client picks from instead of one long expanded scroll.
  String? _expandedDayId;

  static const List<Color> _dayColors = [
    Color(0xFF3D2E8A),
    Color(0xFF2E5EA8),
    Color(0xFF2E8A4A),
    Color(0xFFB5541C),
    Color(0xFF6A2E8A),
    Color(0xFF1B6E6A),
  ];

  String _exerciseName(PlanExerciseEntry ex) => buildBilingualLabel(
    primary: ex.exercise?.nameEn ?? ex.exerciseId,
    arabic: ex.exercise?.nameAr,
    english: ex.exercise?.nameEn,
  );

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final days = [...plan.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return RefreshIndicator(
      onRefresh: () => context.read<WorkoutMyPlanCubit>().loadActive(),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          Text(
            plan.title,
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          if (plan.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              plan.description,
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            'Started ${plan.startDate} • ${plan.dayCount} days',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          ...days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final expanded = _expandedDayId == day.id;
            final color = _dayColors[index % _dayColors.length];
            final exercises = [...day.exercises]
              ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: day.isRest
                    ? AppColors.cardBackground.withValues(alpha: 0.6)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: day.isRest
                    ? Border.all(
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                      )
                    : null,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(
                      () => _expandedDayId = expanded ? null : day.id,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: day.isRest
                                  ? AppColors.textTertiary
                                  : color,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: day.isRest
                                  ? Icon(
                                      Icons.bedtime,
                                      color: Colors.white,
                                      size: 20.sp,
                                    )
                                  : Text(
                                      'D${day.dayNumber}',
                                      style: AppTextStyles.semiBold14(
                                        context,
                                      ).copyWith(color: Colors.white),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.title,
                                  style: AppTextStyles.medium14(
                                    context,
                                  ).copyWith(color: AppColors.textPrimary),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  day.isRest
                                      ? 'Rest day'
                                      : '${day.exerciseCount} Exercises',
                                  style: AppTextStyles.meduim12(
                                    context,
                                  ).copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded) ...[
                    Divider(
                      height: 1,
                      indent: 12.w,
                      endIndent: 12.w,
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                    ),
                    if (day.isRest)
                      Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Text(
                          'Rest day — recover for the next session.',
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else if (exercises.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Text(
                          'No exercises.',
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
                        child: Column(
                          children: exercises
                              .map(
                                (ex) => Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${ex.orderNumber}. ${_exerciseName(ex)}',
                                          style: AppTextStyles.medium14(context)
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '${ex.sets ?? '—'}×${ex.reps ?? '—'} • ${_formatRest(ex.restTime)}',
                                        style: AppTextStyles.meduim12(context)
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: AppColors.textSecondary,
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'No workout plan assigned yet.',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
