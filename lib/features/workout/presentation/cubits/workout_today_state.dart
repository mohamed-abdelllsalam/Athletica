import 'package:athletica/features/workout/domain/entities/today_workout.dart';

sealed class WorkoutTodayState {
  const WorkoutTodayState();

  TodayWorkoutEntry? get workout => null;
}

final class WorkoutTodayInitial extends WorkoutTodayState {
  const WorkoutTodayInitial();
}

final class WorkoutTodayLoading extends WorkoutTodayState {
  const WorkoutTodayLoading();
}

/// Null [workout] means the API answered `{workout: null}` — show the
/// existing empty state ("no workout assigned/today").
/// [errorMessage] carries a failed toggle error while keeping the loaded
/// list visible (load failures still use [WorkoutTodayError]).
final class WorkoutTodayLoaded extends WorkoutTodayState {
  const WorkoutTodayLoaded(this.workout, {this.togglingLogId, this.errorMessage});

  @override
  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
  final String? errorMessage;
}

final class WorkoutTodayError extends WorkoutTodayState {
  const WorkoutTodayError(this.message);
  final String message;
}
