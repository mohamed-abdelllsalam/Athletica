import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_template_sheet.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_workout_card.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutSection extends StatelessWidget {
  const WorkoutSection({super.key, required this.workout});

  final AssignedWorkout? workout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center,
                color: AppColors.primaryBlue, size: 20.sp),
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
          AssignedWorkoutCard(workout: workout!)
        else
          EmptyStateCard(
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
