import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class DeleteWorkoutTemplateUseCase {
  const DeleteWorkoutTemplateUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<void>> call(String templateId) =>
      _repository.deleteTemplate(templateId);
}
