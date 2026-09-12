import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/usecases/complete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_today_workout_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/uncomplete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Client daily workout — `GET /workout/today` + per-exercise
/// complete/uncomplete via `log_id`.
class WorkoutTodayCubit extends Cubit<WorkoutTodayState> {
  WorkoutTodayCubit(this._getToday, this._complete, this._uncomplete)
    : super(const WorkoutTodayInitial());

  final GetTodayWorkoutUseCase _getToday;
  final CompleteWorkoutExerciseUseCase _complete;
  final UncompleteWorkoutExerciseUseCase _uncomplete;

  Future<void> load() async {
    if (state is WorkoutTodayLoading) return;
    emit(const WorkoutTodayLoading());
    final result = await _getToday();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutTodayLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutTodayError(failure.message));
    }
  }

  /// Toggles one exercise. Updates the row locally from the
  /// `{exercise_log, day_completed}` response; surfaces day completion
  /// so the UI can celebrate without a full reload.
  /// Returns `dayCompleted` on success, null on failure/not-loaded.
  Future<bool?> toggle(String logId, bool targetCompleted) async {
    final current = state;
    if (current is! WorkoutTodayLoaded) return null;
    final workout = current.workout;
    if (workout == null || current.togglingLogId != null) return null;

    emit(
      WorkoutTodayLoaded(
        _withCompletion(workout, logId, targetCompleted),
        togglingLogId: logId,
      ),
    );

    final result = targetCompleted
        ? await _complete(logId)
        : await _uncomplete(logId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return null;
        final justConfirmed = !workout.dayCompleted && data.dayCompleted;
        emit(
          WorkoutTodayLoaded(
            _withCompletion(
              workout,
              logId,
              data.completed,
              completedAt: data.completedAt,
              dayCompleted: data.dayCompleted,
            ),
            dayCompletionConfirmed: justConfirmed,
          ),
        );
        return data.dayCompleted;
      case ApiError(:final failure):
        if (isClosed) return null;
        // Revert the optimistic flip but keep the loaded list visible;
        // the error travels on the state so the UI can notify in place.
        emit(WorkoutTodayLoaded(workout, errorMessage: failure.message));
        return null;
    }
  }

  TodayWorkoutEntry _withCompletion(
    TodayWorkoutEntry workout,
    String logId,
    bool completed, {
    DateTime? completedAt,
    bool? dayCompleted,
  }) {
    final updated = workout.exercises
        .map(
          (e) => e.logId == logId
              ? e.copyWith(
                  completed: completed,
                  completedAt: completed
                      ? (completedAt ?? DateTime.now())
                      : null,
                )
              : e,
        )
        .toList();
    final done =
        dayCompleted ??
        (updated.isNotEmpty && updated.every((e) => e.completed));
    return TodayWorkoutEntry(
      dayId: workout.dayId,
      title: workout.title,
      dayNumber: workout.dayNumber,
      isRest: workout.isRest,
      note: workout.note,
      exercises: updated,
      dayCompleted: workout.isRest ? true : done,
    );
  }
}
