import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';

class CreateWorkoutTemplateUseCase {
  const CreateWorkoutTemplateUseCase(this._repository);

  final WorkoutTemplatesRepository _repository;

  Future<ApiResult<WorkoutTemplate>> call({
    required String trainerId,
    required String title,
    required String level,
  }) =>
      _repository.createWorkoutTemplate(
        trainerId: trainerId,
        title: title,
        level: level,
      );
}
