import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class UncompleteWorkoutExerciseUseCase {
  const UncompleteWorkoutExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<ExerciseCompletionResult>> call(String logId) =>
      _repository.uncompleteExercise(logId);
}
