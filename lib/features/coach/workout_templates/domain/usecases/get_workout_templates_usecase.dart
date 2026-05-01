import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';

class GetWorkoutTemplatesUseCase {
  const GetWorkoutTemplatesUseCase(this._repository);

  final WorkoutTemplatesRepository _repository;

  Future<ApiResult<List<WorkoutTemplate>>> call(String trainerId) =>
      _repository.getWorkoutTemplates(trainerId);
}
