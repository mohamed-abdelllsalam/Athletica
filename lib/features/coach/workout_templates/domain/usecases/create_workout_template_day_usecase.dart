import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_day.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';

class CreateWorkoutTemplateDayUseCase {
  const CreateWorkoutTemplateDayUseCase(this._repository);

  final WorkoutTemplatesRepository _repository;

  Future<ApiResult<WorkoutTemplateDay>> call({
    required String workoutTemplateId,
    required int dayIndex,
    required String label,
  }) =>
      _repository.createWorkoutTemplateDay(
        workoutTemplateId: workoutTemplateId,
        dayIndex: dayIndex,
        label: label,
      );
}
