import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';

sealed class WorkoutExercisesState {
  const WorkoutExercisesState();
}

final class WorkoutExercisesInitial extends WorkoutExercisesState {
  const WorkoutExercisesInitial();
}

final class WorkoutExercisesLoading extends WorkoutExercisesState {
  const WorkoutExercisesLoading();
}

final class WorkoutExercisesLoaded extends WorkoutExercisesState {
  const WorkoutExercisesLoaded(this.items, this.pagination);

  final List<WorkoutExerciseEntry> items;
  final ApiPagination pagination;

  bool get hasMore => pagination.hasMore;
}

final class WorkoutExercisesError extends WorkoutExercisesState {
  const WorkoutExercisesError(this.message);
  final String message;
}
