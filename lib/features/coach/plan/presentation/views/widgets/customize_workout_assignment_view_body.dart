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
    return BlocConsumer<CustomizeWorkoutAssignmentCubit,
        CustomizeAssignmentState>(
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
              _Header(
                planName: widget.template.title,
                clientName: widget.clientName,
              ),
              Expanded(
                child: _fields.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            'This plan has no exercises to customize.',
                            style: AppTextStyles.medium14(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                        children: [
                          for (final day in widget.template.days)
                            _DaySection(
                              day: day,
                              fields: _fields
                                  .where((f) => f.dayNumber == day.dayNumber)
                                  .toList(),
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
                      disabledBackgroundColor:
                          AppColors.buttonColor.withValues(alpha: 0.35),
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
                            style: AppTextStyles.semiBold14(context).copyWith(
                              color: Colors.white,
                            ),
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

class _Header extends StatelessWidget {
  const _Header({required this.planName, required this.clientName});

  final String planName;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Customize Workout Assignment',
                  style: AppTextStyles.semiBold15(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '$planName  •  $clientName',
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day, required this.fields});

  final TemplateDayEntry day;
  final List<_ExerciseLoadFields> fields;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${day.dayNumber} — ${day.title}',
            style: AppTextStyles.semiBold14(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (day.note.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              day.note,
              style: AppTextStyles.meduim12(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          if (day.isRest || fields.isEmpty)
            Text(
              'Rest day — no exercises to customize.',
              style: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final field in fields) _ExerciseCard(field: field),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.field});

  final _ExerciseLoadFields field;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.name,
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _LoadField(
                  label: 'Sets',
                  hint: '4',
                  controller: field.sets,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LoadField(
                  label: 'Reps',
                  hint: '10',
                  controller: field.reps,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LoadField(
                  label: 'Rest (s)',
                  hint: '90',
                  controller: field.rest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadField extends StatelessWidget {
  const _LoadField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
