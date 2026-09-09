import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetTodayWorkoutUseCase {
  const GetTodayWorkoutUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<TodayWorkoutEntry?>> call() => _repository.getTodayWorkout();
}
