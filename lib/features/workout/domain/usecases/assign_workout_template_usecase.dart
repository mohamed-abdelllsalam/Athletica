import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class AssignWorkoutTemplateUseCase {
  const AssignWorkoutTemplateUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> call(
    String templateId, {
    required String coachClientId,
    String? title,
    String? description,
  }) =>
      _repository.assignTemplate(
        templateId,
        coachClientId: coachClientId,
        title: title,
        description: description,
      );
}
