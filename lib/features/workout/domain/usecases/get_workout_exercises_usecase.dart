import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutExercisesUseCase {
  const GetWorkoutExercisesUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<({List<WorkoutExerciseEntry> items, ApiPagination pagination})>>
      call(WorkoutExerciseFilters filters) => _repository.getExercises(filters);
}
