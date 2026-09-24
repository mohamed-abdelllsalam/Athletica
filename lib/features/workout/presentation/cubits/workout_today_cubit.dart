import 'dart:async';
import 'package:athletica/core/usecases/watch_completion_changes_usecase.dart';
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
  WorkoutTodayCubit(
    this._getToday,
    this._complete,
    this._uncomplete, [
    WatchCompletionChangesUseCase? changes,
  ]) : super(const WorkoutTodayInitial()) {
    _subscription = changes?.call().listen((_) => load());
  }

  final GetTodayWorkoutUseCase _getToday;
  final CompleteWorkoutExerciseUseCase _complete;
  final UncompleteWorkoutExerciseUseCase _uncomplete;

  StreamSubscription<void>? _subscription;
  bool _reloadRequested = false;
  bool _loadInProgress = false;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> load() async {
    if (isClosed) return;
    final current = state;
    if (current is WorkoutTodayLoaded && current.togglingLogId != null) return;
    if (_loadInProgress) {
      _reloadRequested = true;
      return;
    }
    _loadInProgress = true;
    if (current is! WorkoutTodayLoaded) emit(const WorkoutTodayLoading());
    try {
      final result = await _getToday();
      if (isClosed) return;
      switch (result) {
        case ApiSuccess(:final data):
          emit(WorkoutTodayLoaded(data));
        case ApiError(:final failure):
          emit(
            current is WorkoutTodayLoaded
                ? WorkoutTodayLoaded(
                    current.workout,
                    errorMessage: failure.message,
                  )
                : WorkoutTodayError(failure.message),
          );
      }
    } finally {
      _loadInProgress = false;
      if (_reloadRequested && !isClosed) {
        _reloadRequested = false;
        await load();
      }
    }
  }

  /// Toggles one exercise after backend confirmation. Updates the row from the
  /// `{exercise_log, day_completed}` response; surfaces day completion
  /// so the UI can celebrate without a full reload.
  /// Returns `dayCompleted` on success, null on failure/not-loaded.
  Future<bool?> toggle(String logId, bool targetCompleted) async {
    final current = state;
    if (current is! WorkoutTodayLoaded || _loadInProgress) return null;
    final workout = current.workout;
    if (workout == null || current.togglingLogId != null) return null;

    final exercise = workout.exercises
        .where((e) => e.logId == logId)
        .firstOrNull;
    if (logId.isEmpty ||
        exercise == null ||
        exercise.completed == targetCompleted) {
      return null;
    }
    emit(WorkoutTodayLoaded(workout, togglingLogId: logId));

    final result = targetCompleted
        ? await _complete(logId)
        : await _uncomplete(logId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return null;
        if (data.logId != logId) {
          emit(
            WorkoutTodayLoaded(
              workout,
              errorMessage:
                  'Could not confirm exercise status. Please refresh.',
            ),
          );
          return null;
        }
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
        // Keep confirmed data visible on failure;
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
    required bool dayCompleted,
  }) {
    final updated = workout.exercises
        .map(
          (e) => e.logId == logId
              ? e.copyWith(
                  completed: completed,
                  completedAt: completed ? completedAt : null,
                )
              : e,
        )
        .toList();
    return TodayWorkoutEntry(
      dayId: workout.dayId,
      title: workout.title,
      dayNumber: workout.dayNumber,
      isRest: workout.isRest,
      note: workout.note,
      exercises: updated,
      dayCompleted: dayCompleted,
    );
  }
}
