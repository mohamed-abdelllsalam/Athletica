import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_day_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_item_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_usecase.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/save_workout_plan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveWorkoutPlanCubit extends Cubit<SaveWorkoutPlanState> {
  SaveWorkoutPlanCubit(
    this._createTemplate,
    this._createDay,
    this._createItem,
  ) : super(SaveWorkoutPlanIdle());

  final CreateWorkoutTemplateUseCase _createTemplate;
  final CreateWorkoutTemplateDayUseCase _createDay;
  final CreateWorkoutTemplateItemUseCase _createItem;

  Future<void> savePlan(WorkoutProgram program) async {
    if (state is SaveWorkoutPlanLoading) return;
    emit(SaveWorkoutPlanLoading());

    final trainerId = await TokenStorageService.instance.getTrainerId();
    if (trainerId == null) {
      if (isClosed) return;
      emit(SaveWorkoutPlanError('Trainer ID not found. Please log in again.'));
      return;
    }

    // 1. Create the template
    final templateResult = await _createTemplate(
      trainerId: trainerId,
      title: program.name,
      level: _categoryToLevel(program.category),
    );

    final String templateId;
    switch (templateResult) {
      case ApiSuccess(:final data):
        templateId = data.id;
      case ApiError(:final failure):
        if (isClosed) return;
        emit(SaveWorkoutPlanError(failure.message));
        return;
    }

    // 2. Create each day, then its exercises
    for (int i = 0; i < program.days.length; i++) {
      final day = program.days[i];

      final dayResult = await _createDay(
        workoutTemplateId: templateId,
        dayIndex: i,
        label: day.name,
      );

      final String dayId;
      switch (dayResult) {
        case ApiSuccess(:final data):
          dayId = data.id;
        case ApiError(:final failure):
          if (isClosed) return;
          emit(SaveWorkoutPlanError(failure.message));
          return;
      }

      // 3. Create exercises for this day — skip local mock IDs (non-UUID)
      for (int j = 0; j < day.exercises.length; j++) {
        final exercise = day.exercises[j];
        if (!_isValidUuid(exercise.id)) continue;
        final itemResult = await _createItem(
          CreateWorkoutTemplateItemParams(
            workoutTemplateDayId: dayId,
            exerciseId: exercise.id,
            order: j + 1,
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
        );
        switch (itemResult) {
          case ApiError(:final failure):
            if (isClosed) return;
            emit(SaveWorkoutPlanError(failure.message));
            return;
          case ApiSuccess():
            break;
        }
      }
    }

    if (isClosed) return;
    emit(SaveWorkoutPlanSuccess());
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  bool _isValidUuid(String id) => _uuidRegex.hasMatch(id);

  String _categoryToLevel(String category) => switch (category) {
        'Strength' || 'Boxing' => 'ADVANCED',
        'Fat loss' => 'INTERMEDIATE',
        _ => 'BEGINNER',
      };
}
