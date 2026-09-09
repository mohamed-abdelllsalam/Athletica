import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class CreateWorkoutTemplateV1UseCase {
  const CreateWorkoutTemplateV1UseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call({
    required String title,
    required String description,
  }) =>
      _repository.createTemplate(title: title, description: description);
}
