import 'workout_assignment_exercise_card.dart';
import 'workout_assignment_day_section.dart';
import 'workout_assignment_header.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/customize_workout_assignment_cubit.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One exercise row's load inputs. Controllers are created in `initState`
/// and disposed with the state.
class _ExerciseLoadFields {
  _ExerciseLoadFields({
    required this.dayNumber,
    required this.exerciseOrder,
    required this.name,
  });

  final int dayNumber;
  final int exerciseOrder;
  final String name;
  final TextEditingController sets = TextEditingController();
  final TextEditingController reps = TextEditingController();
  final TextEditingController rest = TextEditingController();

  void dispose() {
    sets.dispose();
    reps.dispose();
    rest.dispose();
  }
}

class CustomizeWorkoutAssignmentViewBody extends StatefulWidget {
  const CustomizeWorkoutAssignmentViewBody({
    super.key,
    required this.template,
    required this.coachClientId,
    required this.clientName,
  });

  final WorkoutTemplateEntry template;
  final String coachClientId;
  final String clientName;

  @override
  State<CustomizeWorkoutAssignmentViewBody> createState() =>
      _CustomizeWorkoutAssignmentViewBodyState();
}

class _CustomizeWorkoutAssignmentViewBodyState
    extends State<CustomizeWorkoutAssignmentViewBody> {
  late final List<_ExerciseLoadFields> _fields;

  @override
  void initState() {
    super.initState();
    // Template exercises carry no loads (sets/reps always null server-side),
    // so fields start empty = "leave unset, fill later". Rest days have no
    // exercises and produce no fields.
    _fields = [
      for (final day in widget.template.days)
        if (!day.isRest)
          for (final exercise in day.exercises)
            _ExerciseLoadFields(
              dayNumber: day.dayNumber,
              exerciseOrder: exercise.exerciseOrder,
              name: _exerciseName(exercise),
            ),
    ];
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  String _exerciseName(TemplateExerciseEntry e) => buildBilingualLabel(
    primary: (e.exercise?.nameEn.isNotEmpty ?? false)
        ? e.exercise!.nameEn
        : e.exerciseId,
    arabic: e.exercise?.nameAr,
    english: e.exercise?.nameEn,
  );

  void _submit() {
    for (final field in _fields) {
      if (!isValidLoadValue(field.sets.text) ||
          !isValidLoadValue(field.reps.text) ||
          !isValidLoadValue(field.rest.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sets, reps and rest must be positive numbers.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    FocusScope.of(context).unfocus();
    context.read<CustomizeWorkoutAssignmentCubit>().submit(
      templateId: widget.template.id,
      coachClientId: widget.coachClientId,
      loads: [
        for (final field in _fields)
          ExerciseLoadInput(
            dayNumber: field.dayNumber,
            exerciseOrder: field.exerciseOrder,
            sets: parseLoadValue(field.sets.text),
            reps: parseLoadValue(field.reps.text),
            restTime: parseLoadValue(field.rest.text),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CustomizeWorkoutAssignmentCubit,
      CustomizeAssignmentState
    >(
      listener: (context, state) {
        switch (state) {
          case CustomizeAssignmentSuccess(:final planId):
            Navigator.pop(context, planId);
          case CustomizeAssignmentFailure(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          case CustomizeAssignmentInitial():
          case CustomizeAssignmentSubmitting():
            break;
        }
      },
      builder: (context, state) {
        final submitting = state is CustomizeAssignmentSubmitting;
        return UnfocusOnTap(
          child: Column(
            children: [
              CoachWorkoutAssignmentHeader(
                planName: widget.template.title,
                clientName: widget.clientName,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: _fields.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            'This plan has no exercises to customize.',
                            style: AppTextStyles.medium14(
                              context,
                            ).copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                        children: [
                          for (final day in widget.template.days)
                            CoachWorkoutAssignmentDaySection(
                              day: day,
                              exerciseCards: [
                                for (final field in _fields.where(
                                  (f) => f.dayNumber == day.dayNumber,
                                ))
                                  CoachWorkoutAssignmentExerciseCard(
                                    name: field.name,
                                    sets: field.sets,
                                    reps: field.reps,
                                    rest: field.rest,
                                  ),
                              ],
                            ),
                        ],
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: submitting || _fields.isEmpty ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      disabledBackgroundColor: AppColors.buttonColor.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: submitting
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Assign Workout',
                            style: AppTextStyles.semiBold14(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
