import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutPlanDetailUseCase {
  const GetWorkoutPlanDetailUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> call(String planId) =>
      _repository.getPlan(planId);
}
