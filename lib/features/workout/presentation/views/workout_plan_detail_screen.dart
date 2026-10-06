import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/workout_assigned_day_card.dart';
import 'widgets/workout_prescription_fields.dart';

/// Coach view of one assigned plan — `GET /workout/plans/:pid` +
/// per-exercise `{sets, reps}` editing. Same card/row styling as the
/// template detail; sets/reps are positive ints per API docs.
class WorkoutPlanDetailScreen extends StatelessWidget {
  const WorkoutPlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutPlanDetailCubit>()..load(planId),
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _Body(planId: planId)),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutPlanDetailCubit, WorkoutPlanDetailState>(
      builder: (context, state) => switch (state) {
        WorkoutPlanDetailInitial() || WorkoutPlanDetailLoading() =>
          const Center(child: CircularProgressIndicator()),
        WorkoutPlanDetailError(connectionError: true) => ConnectionErrorView(onRetry: () => context.read<WorkoutPlanDetailCubit>().load(planId)),
        WorkoutPlanDetailError(:final message) => Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
        WorkoutPlanDetailLoaded(:final plan, :final mutating) => Column(children: [
          if (state.connectionError) ConnectionErrorView(compact: true, onRetry: () => context.read<WorkoutPlanDetailCubit>().load(planId)),
          Expanded(child: _Content(plan: plan, mutating: mutating)),
        ]),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.plan, required this.mutating});

  final WorkoutPlanEntry plan;
  final bool mutating;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final days = [...plan.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
            const Spacer(),
            if (mutating)
              SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          plan.title,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          'Started ${plan.startDate} • ${plan.dayCount} days • cycle ${plan.cycleDays}',
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        if (plan.description.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            plan.description,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
        SizedBox(height: 20.h),
        if (days.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No days in this plan yet.',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...days.map((day) {
            final exercises = [...day.exercises]
              ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
            return WorkoutAssignedDayCard(
              day: day,
              exercises: exercises
                  .map(
                    (ex) => _ExerciseRow(
                      exercise: ex,
                      dayId: day.id,
                      isArabic: _isArabic(context),
                    ),
                  )
                  .toList(),
            );
          }),
      ],
    );
  }
}

class _ExerciseRow extends StatefulWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.dayId,
    required this.isArabic,
  });

  final PlanExerciseEntry exercise;
  final String dayId;
  final bool isArabic;

  @override
  State<_ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<_ExerciseRow> {
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.exercise.reps?.toString() ?? '',
    );
    _restController = TextEditingController(
      text: widget.exercise.restTime?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ExerciseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.sets != widget.exercise.sets) {
      _setsController.text = widget.exercise.sets?.toString() ?? '';
    }
    if (oldWidget.exercise.reps != widget.exercise.reps) {
      _repsController.text = widget.exercise.reps?.toString() ?? '';
    }
    if (oldWidget.exercise.restTime != widget.exercise.restTime) {
      _restController.text = widget.exercise.restTime?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final rest = int.tryParse(_restController.text.trim());
    if ((sets != null && sets <= 0) ||
        (reps != null && reps <= 0) ||
        (rest != null && rest <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sets, reps and rest must be positive.')),
      );
      return;
    }
    final ok = await context.read<WorkoutPlanDetailCubit>().setSetsReps(
      widget.dayId,
      widget.exercise.id,
      sets: sets,
      reps: reps,
      restTime: rest,
    );
    if (!mounted) return;
    if (!ok) {
      final err = context.read<WorkoutPlanDetailCubit>().lastError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Update failed')));
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise.exercise;
    final name = buildBilingualLabel(
      primary: ex?.nameEn ?? widget.exercise.exerciseId,
      arabic: ex?.nameAr,
      english: ex?.nameEn,
    );
    return WorkoutPrescriptionFields(
      exercise: widget.exercise,
      name: name,
      setsController: _setsController,
      repsController: _repsController,
      restController: _restController,
      onSave: _save,
    );
  }
}
