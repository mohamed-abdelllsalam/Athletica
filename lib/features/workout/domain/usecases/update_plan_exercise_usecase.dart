import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class UpdatePlanExerciseUseCase {
  const UpdatePlanExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> call(
    String planId,
    String dayId,
    String exerciseId, {
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) =>
      _repository.updatePlanExercise(
        planId,
        dayId,
        exerciseId,
        orderNumber: orderNumber,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
      );
}
