import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/network/api_pagination.dart';
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
  List<WorkoutExerciseEntry>? _fullCache;
  AppFailure? _libraryFailure;

  WorkoutExerciseFilters get filters => _filters;

  Future<void> load({
    WorkoutExerciseFilters? filters,
    bool refresh = true,
  }) async {
    if (state is WorkoutExercisesLoading) return;
    if (filters != null) _filters = filters;
    final previous = state;
    if (previous is! WorkoutExercisesLoaded) {
      emit(const WorkoutExercisesLoading());
    }

    final result = await _getExercises(_filters);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutExercisesLoaded(data.items, data.pagination));
      case ApiError(:final failure):
        if (isClosed) return;
        if (failure is NetworkFailure && previous is WorkoutExercisesLoaded) {
          emit(
            WorkoutExercisesLoaded(
              previous.items,
              previous.pagination,
              connectionError: true,
            ),
          );
        } else {
          emit(
            WorkoutExercisesError(
              failure.message,
              connectionError: failure is NetworkFailure,
            ),
          );
        }
    }
  }

  Future<void> search(String query) => load(
    filters: _filters.copyWith(search: query.isEmpty ? null : query, page: 1),
  );

  /// Full-library search across names, aliases and muscles — a superset of
  /// the server `search` (which only covers names/aliases). Pages through
  /// the whole catalog once per cubit lifetime, then filters in memory.
  /// Optional [bodyPart] narrows further (exact match, case-insensitive).
  /// Emits a single self-contained page, so `loadMore` safely no-ops after.
  Future<void> searchLibrary(String query, {String? bodyPart}) async {
    if (state is WorkoutExercisesLoading) return;
    final previous = state;
    if (previous is! WorkoutExercisesLoaded) {
      emit(const WorkoutExercisesLoading());
    }

    final all = await _ensureFullLibrary();
    if (isClosed) return;
    if (all == null) {
      if (_libraryFailure is NetworkFailure &&
          previous is WorkoutExercisesLoaded) {
        emit(
          WorkoutExercisesLoaded(
            previous.items,
            previous.pagination,
            connectionError: true,
          ),
        );
      } else {
        emit(
          WorkoutExercisesError(
            _libraryFailure?.message ??
                'Could not load the exercise library. Please try again.',
            connectionError: _libraryFailure is NetworkFailure,
          ),
        );
      }
      return;
    }
    final items = all.where((e) {
      if (bodyPart != null &&
          e.bodyPart.toLowerCase() != bodyPart.toLowerCase()) {
        return false;
      }
      return e.matchesQuery(query);
    }).toList();
    if (isClosed) return;
    emit(
      WorkoutExercisesLoaded(
        items,
        ApiPagination(
          page: 1,
          pageSize: items.length,
          total: items.length,
          totalPages: 1,
        ),
      ),
    );
  }

  Future<List<WorkoutExerciseEntry>?> _ensureFullLibrary() async {
    _libraryFailure = null;
    if (_fullCache != null) return _fullCache;
    const pageSize = 100;
    final all = <WorkoutExerciseEntry>[];
    var page = 1;
    while (page <= 20) {
      final result = await _getExercises(
        WorkoutExerciseFilters(page: page, pageSize: pageSize),
      );
      switch (result) {
        case ApiSuccess(:final data):
          all.addAll(data.items);
          if (!data.pagination.hasMore) {
            _fullCache = all;
            return all;
          }
          page++;
        case ApiError(:final failure):
          _libraryFailure = failure;
          return null;
      }
      if (isClosed) return null;
    }
    _fullCache = all;
    return all;
  }

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
          WorkoutExercisesLoaded([
            ...current.items,
            ...data.items,
          ], data.pagination),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        _filters = _filters.copyWith(page: _filters.page - 1);
        if (failure is NetworkFailure) {
          emit(
            WorkoutExercisesLoaded(
              current.items,
              current.pagination,
              connectionError: true,
            ),
          );
        } else {
          emit(WorkoutExercisesError(failure.message));
        }
    }
  }
}
