import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_item.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';

class CreateWorkoutTemplateItemParams {
  const CreateWorkoutTemplateItemParams({
    required this.workoutTemplateDayId,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
    this.tempo,
    this.rir,
    this.rpe,
  });

  final String workoutTemplateDayId;
  final String exerciseId;
  final int order;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  final String? tempo;
  final int? rir;
  final int? rpe;
}

class CreateWorkoutTemplateItemUseCase {
  const CreateWorkoutTemplateItemUseCase(this._repository);

  final WorkoutTemplatesRepository _repository;

  Future<ApiResult<WorkoutTemplateItem>> call(
    CreateWorkoutTemplateItemParams params,
  ) =>
      _repository.createWorkoutTemplateItem(
        workoutTemplateDayId: params.workoutTemplateDayId,
        exerciseId: params.exerciseId,
        order: params.order,
        sets: params.sets,
        reps: params.reps,
        restSeconds: params.restSeconds,
        notes: params.notes,
        tempo: params.tempo,
        rir: params.rir,
        rpe: params.rpe,
      );
}
