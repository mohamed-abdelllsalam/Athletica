import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class CompleteWorkoutExerciseUseCase {
  const CompleteWorkoutExerciseUseCase(this._repository);
  final WorkoutRepository _repository;

  /// [logId] is the `log_id` from `/today` — never the exercise id.
  Future<ApiResult<ExerciseCompletionResult>> call(String logId) =>
      _repository.completeExercise(logId);
}
