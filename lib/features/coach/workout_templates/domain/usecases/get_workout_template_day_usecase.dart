import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_day.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';

class GetWorkoutTemplateDayUseCase {
  const GetWorkoutTemplateDayUseCase(this._repository);

  final WorkoutTemplatesRepository _repository;

  Future<ApiResult<WorkoutTemplateDay>> call(String dayId) =>
      _repository.getWorkoutTemplateDayById(dayId);
}
