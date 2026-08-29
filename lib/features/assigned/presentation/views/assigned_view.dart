import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_template_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignedView extends StatelessWidget {
  const AssignedView({super.key});

  static const String routeName = 'assigned-view';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AssignedCubit>()..loadAssigned(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _AssignedBody()),
      ),
    );
  }
}

class _AssignedBody extends StatelessWidget {
  const _AssignedBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: BlocBuilder<AssignedCubit, AssignedState>(
            builder: (context, state) {
              if (state is AssignedLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AssignedError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.textSecondary, size: 48.sp),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: AppTextStyles.medium14(context)
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<AssignedCubit>().loadAssigned(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is AssignedLoaded) {
                return _buildContent(context, state.assigned);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
            'Assigned Plans',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientAssigned assigned) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _WorkoutSection(workout: assigned.workout),
          SizedBox(height: 24.h),
          _NutritionSection(nutrition: assigned.nutrition),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

// ── Workout Section ──────────────────────────────────────────────────────────

class _WorkoutSection extends StatelessWidget {
  const _WorkoutSection({required this.workout});

  final AssignedWorkout? workout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center, color: AppColors.primaryBlue, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Workout',
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (workout != null)
          _AssignedWorkoutCard(workout: workout!)
        else
          _EmptyCard(
            icon: Icons.fitness_center,
            label: 'No workout assigned',
            buttonLabel: 'Assign Workout',
            onPressed: () => _openWorkoutSheet(context),
          ),
      ],
    );
  }

  void _openWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AssignedCubit>(),
        child: const AssignTemplateSheet(type: AssignType.workout),
      ),
    );
  }
}

class _AssignedWorkoutCard extends StatelessWidget {
  const _AssignedWorkoutCard({required this.workout});

  final AssignedWorkout workout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.fitness_center,
                color: AppColors.primaryBlue, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: AppTextStyles.semiBold15(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                if (workout.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    workout.description!,
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.streakGreen, size: 22.sp),
        ],
      ),
    );
  }
}

// ── Nutrition Section ────────────────────────────────────────────────────────

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.nutrition});

  final AssignedNutrition? nutrition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long,
                color: AppColors.streakGreen, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Nutrition',
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (nutrition != null)
          _AssignedNutritionCard(nutrition: nutrition!)
        else
          _EmptyCard(
            icon: Icons.receipt_long,
            label: 'No nutrition plan assigned',
            buttonLabel: 'Assign Nutrition',
            onPressed: () => _openNutritionSheet(context),
          ),
      ],
    );
  }

  void _openNutritionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AssignedCubit>(),
        child: const AssignTemplateSheet(type: AssignType.nutrition),
      ),
    );
  }
}

class _AssignedNutritionCard extends StatelessWidget {
  const _AssignedNutritionCard({required this.nutrition});

  final AssignedNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.streakGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.streakGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.receipt_long,
                color: AppColors.streakGreen, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nutrition.title,
                  style: AppTextStyles.semiBold15(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                if (nutrition.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    nutrition.description!,
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.streakGreen, size: 22.sp),
        ],
      ),
    );
  }
}

// ── Empty Card ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.label,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.surfaceDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 36.sp),
          SizedBox(height: 12.h),
          Text(
            label,
            style: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: AppTextStyles.semiBold14(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
