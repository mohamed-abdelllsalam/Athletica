import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return BlocBuilder<WorkoutPlanDetailCubit, WorkoutPlanDetailState>(
      builder: (context, state) => switch (state) {
        WorkoutPlanDetailInitial() || WorkoutPlanDetailLoading() =>
          const Center(child: CircularProgressIndicator()),
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
        WorkoutPlanDetailLoaded(:final plan, :final mutating) => _Content(
          plan: plan,
          mutating: mutating,
        ),
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
          ...days.map(
            (day) => _DayCard(
              day: day,
              isArabic: _isArabic(context),
              planId: plan.id,
            ),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.isArabic,
    required this.planId,
  });

  final PlanDayEntry day;
  final bool isArabic;
  final String planId;

  @override
  Widget build(BuildContext context) {
    final exercises = [...day.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Day ${day.dayNumber} — ${day.title}',
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (day.isRest)
                Text(
                  'Rest',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (!day.isRest && exercises.isEmpty)
            Text(
              'No exercises yet.',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            )
          else
            ...exercises.map(
              (ex) =>
                  _ExerciseRow(exercise: ex, dayId: day.id, isArabic: isArabic),
            ),
        ],
      ),
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

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.exercise.reps?.toString() ?? '',
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
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    if ((sets != null && sets <= 0) || (reps != null && reps <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sets and reps must be positive.')),
      );
      return;
    }
    final ok = await context.read<WorkoutPlanDetailCubit>().setSetsReps(
      widget.dayId,
      widget.exercise.id,
      sets: sets,
      reps: reps,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.exercise.orderNumber}. $name',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                if (widget.exercise.notes.isNotEmpty)
                  Text(
                    widget.exercise.notes,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 52.w,
            child: TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Sets',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 52.w,
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Reps',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: _save,
            child: Icon(Icons.check, color: AppColors.streakGreen, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
