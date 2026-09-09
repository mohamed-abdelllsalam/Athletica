import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class DeleteWorkoutPlanUseCase {
  const DeleteWorkoutPlanUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<void>> call(String planId) => _repository.deletePlan(planId);
}
