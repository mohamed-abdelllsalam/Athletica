import 'workout_editor_sections.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_search_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_day_exercises_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutEditorViewBody extends StatefulWidget {
  const WorkoutEditorViewBody({super.key, required this.clientName});

  final String clientName;

  @override
  State<WorkoutEditorViewBody> createState() => _WorkoutEditorViewBodyState();
}

class _WorkoutEditorViewBodyState extends State<WorkoutEditorViewBody> {
  int _day = 1;
  List<PlanExercise> _warmUp = [];
  List<PlanExercise> _workout = [];
  List<PlanExercise> _coolDown = [];
  final TextEditingController _summaryController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickExercises(String section) async {
    final result = await Navigator.push<List<PlanExercise>>(
      context,
      MaterialPageRoute(builder: (_) => const ExerciseSearchView()),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      switch (section) {
        case 'warmUp':
          _warmUp = [..._warmUp, ...result];
        case 'workout':
          _workout = [..._workout, ...result];
        case 'coolDown':
          _coolDown = [..._coolDown, ...result];
      }
    });
  }

  void _viewDay() {
    ProgramExercise toProgramExercise(PlanExercise e) => ProgramExercise(
      id: e.id,
      name: e.name,
      thumbnailUrl: e.thumbnailUrl,
      videoUrlMale: e.videoUrlMale,
      videoUrlFemale: e.videoUrlFemale,
    );
    final day = ProgramDay(
      dayNumber: _day,
      name: 'Day $_day',
      durationMinutes: 60,
      exercises: [
        // PlanExercise.name already carries the bilingual label.
        ..._warmUp.map(toProgramExercise),
        ..._workout.map(toProgramExercise),
        ..._coolDown.map(toProgramExercise),
      ],
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutDayExercisesView(day: day)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
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
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Upload Pdf Program',
                  style: AppTextStyles.meduim12(context).copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CoachWorkoutEditorDayCounter(
            day: _day,
            onDecrement: () {
              if (_day > 1) setState(() => _day--);
            },
            onIncrement: () => setState(() => _day++),
          ),
          SizedBox(height: 20.h),
          CoachWorkoutEditorSectionLabel(label: 'Warm Up'),
          SizedBox(height: 8.h),
          CoachWorkoutEditorAddExerciseButton(
            onTap: () => _pickExercises('warmUp'),
            addedCount: _warmUp.length,
          ),
          SizedBox(height: 16.h),
          CoachWorkoutEditorSectionLabel(label: 'Workout'),
          SizedBox(height: 8.h),
          CoachWorkoutEditorAddExerciseButton(
            onTap: () => _pickExercises('workout'),
            addedCount: _workout.length,
          ),
          SizedBox(height: 16.h),
          CoachWorkoutEditorSectionLabel(label: 'Cool Down'),
          SizedBox(height: 8.h),
          CoachWorkoutEditorAddExerciseButton(
            onTap: () => _pickExercises('coolDown'),
            addedCount: _coolDown.length,
          ),
          SizedBox(height: 20.h),
          Text(
            'Summary',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _summaryController,
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Summary of your exercise',
                hintStyle: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textPrimary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: _viewDay,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
