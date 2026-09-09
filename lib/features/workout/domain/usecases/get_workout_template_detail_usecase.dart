import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutTemplateDetailUseCase {
  const GetWorkoutTemplateDetailUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call(String templateId) =>
      _repository.getTemplate(templateId);
}
