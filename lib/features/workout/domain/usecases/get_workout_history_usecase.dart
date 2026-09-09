import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_history.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutHistoryUseCase {
  const GetWorkoutHistoryUseCase(this._repository);
  final WorkoutRepository _repository;

  /// Param-less — backend derives the range from plan start_date to today.
  Future<ApiResult<List<WorkoutHistoryDay>>> call() => _repository.getHistory();
}
