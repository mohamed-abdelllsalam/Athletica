import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class AddTemplateExerciseUseCase {
  const AddTemplateExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call(
    String templateId,
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  }) =>
      _repository.addTemplateExercise(
        templateId,
        dayId,
        exerciseId: exerciseId,
        exerciseOrder: exerciseOrder,
        notes: notes,
      );
}
