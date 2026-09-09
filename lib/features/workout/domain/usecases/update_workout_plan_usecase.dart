import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class UpdateWorkoutPlanUseCase {
  const UpdateWorkoutPlanUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> call(
    String planId, {
    String? title,
    String? description,
  }) =>
      _repository.updatePlan(planId, title: title, description: description);
}
