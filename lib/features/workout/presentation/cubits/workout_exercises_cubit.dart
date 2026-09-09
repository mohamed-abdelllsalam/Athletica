import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_exercises_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coach exercise library — `GET /workout/exercises` with API filters.
/// Depends only on use cases, never on repositories/datasources.
class WorkoutExercisesCubit extends Cubit<WorkoutExercisesState> {
  WorkoutExercisesCubit(this._getExercises)
      : super(const WorkoutExercisesInitial());

  final GetWorkoutExercisesUseCase _getExercises;
  WorkoutExerciseFilters _filters = const WorkoutExerciseFilters();

  WorkoutExerciseFilters get filters => _filters;

  Future<void> load({WorkoutExerciseFilters? filters, bool refresh = true}) async {
    if (state is WorkoutExercisesLoading) return;
    if (filters != null) _filters = filters;
    if (refresh) emit(const WorkoutExercisesLoading());

    final result = await _getExercises(_filters);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutExercisesLoaded(data.items, data.pagination));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutExercisesError(failure.message));
    }
  }

  Future<void> search(String query) =>
      load(filters: _filters.copyWith(search: query.isEmpty ? null : query, page: 1));

  Future<void> loadMore() async {
    final current = state;
    if (current is! WorkoutExercisesLoaded || !current.hasMore) return;
    final next = _filters.copyWith(page: _filters.page + 1);
    _filters = next;
    final result = await _getExercises(next);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(
          WorkoutExercisesLoaded(
            [...current.items, ...data.items],
            data.pagination,
          ),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        _filters = _filters.copyWith(page: _filters.page - 1);
        emit(WorkoutExercisesError(failure.message));
    }
  }
}
