import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class DeleteTemplateExerciseUseCase {
  const DeleteTemplateExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call(
    String templateId,
    String dayId,
    String exerciseId,
  ) =>
      _repository.deleteTemplateExercise(templateId, dayId, exerciseId);
}
