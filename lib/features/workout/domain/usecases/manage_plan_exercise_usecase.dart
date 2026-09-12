import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class ManagePlanExerciseUseCase {
  const ManagePlanExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> add(
    String planId,
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) =>
      _repository.addPlanExercise(
        planId,
        dayId,
        exerciseId: exerciseId,
        orderNumber: orderNumber,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
      );

  Future<ApiResult<WorkoutPlanEntry>> delete(
    String planId,
    String dayId,
    String exerciseId,
  ) =>
      _repository.deletePlanExercise(planId, dayId, exerciseId);
}
