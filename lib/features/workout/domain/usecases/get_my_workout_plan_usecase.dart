import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetMyWorkoutPlanUseCase {
  const GetMyWorkoutPlanUseCase(this._repository);
  final WorkoutRepository _repository;

  /// Returns null when the client has no active plan (`plan: null`).
  Future<ApiResult<WorkoutPlanEntry?>> call() => _repository.getMyActivePlan();
}
