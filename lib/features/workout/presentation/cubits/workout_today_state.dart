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
  const WorkoutTodayLoaded(
    this.workout, {
    this.togglingLogId,
    this.errorMessage,
    this.isConnectionError = false,
    this.dayCompletionConfirmed = false,
  });

  @override
  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
  final String? errorMessage;
  final bool isConnectionError;

  /// True only on the successful backend response that changes an incomplete
  /// day to complete. It is never set by the optimistic update or initial load.
  final bool dayCompletionConfirmed;
}

final class WorkoutTodayError extends WorkoutTodayState {
  const WorkoutTodayError(this.message, {this.isConnectionError = false});
  final bool isConnectionError;
  final String message;
}
