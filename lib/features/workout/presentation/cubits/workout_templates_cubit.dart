import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/features/workout/domain/usecases/create_workout_template_v1_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_templates_v1_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutTemplatesCubit extends Cubit<WorkoutTemplatesState> {
  WorkoutTemplatesCubit(
    this._getTemplates,
    this._createTemplate,
    this._deleteTemplate,
  ) : super(const WorkoutTemplatesInitial());

  final GetWorkoutTemplatesV1UseCase _getTemplates;
  final CreateWorkoutTemplateV1UseCase _createTemplate;
  final DeleteWorkoutTemplateUseCase _deleteTemplate;

  bool _mutating = false;

  Future<void> load({int page = 1, int pageSize = 10}) async {
    if (state is WorkoutTemplatesLoading) return;
    final previous = state;
    if (previous is! WorkoutTemplatesLoaded) {
      emit(const WorkoutTemplatesLoading());
    }
    final result = await _getTemplates(page: page, pageSize: pageSize);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutTemplatesLoaded(data.items, data.pagination));
      case ApiError(:final failure):
        if (isClosed) return;
        if (failure is NetworkFailure && previous is WorkoutTemplatesLoaded) {
          emit(
            WorkoutTemplatesLoaded(
              previous.items,
              previous.pagination,
              connectionError: true,
            ),
          );
        } else {
          emit(
            WorkoutTemplatesError(
              failure.message,
              connectionError: failure is NetworkFailure,
            ),
          );
        }
    }
  }

  Future<void> refresh() => load();

  /// Creates `{title, description}` then reloads the list. Guards
  /// against duplicate taps while the mutation is in flight. Returns
  /// true on success; on failure the loaded list is kept and the error
  /// is exposed on [WorkoutTemplatesLoaded.mutationError].
  Future<bool> create({
    required String title,
    required String description,
  }) async {
    if (_mutating) return false;
    final current = state;
    _mutating = true;
    if (current is WorkoutTemplatesLoaded) {
      emit(
        WorkoutTemplatesLoaded(
          current.items,
          current.pagination,
          mutating: true,
        ),
      );
    }
    final result = await _createTemplate(
      title: title,
      description: description,
    );
    switch (result) {
      case ApiSuccess():
        _mutating = false;
        await load();
        return true;
      case ApiError(:final failure):
        _mutating = false;
        if (isClosed) return false;
        final now = state;
        if (now is WorkoutTemplatesLoaded) {
          emit(
            WorkoutTemplatesLoaded(
              now.items,
              now.pagination,
              mutationError: failure.message,
            ),
          );
        } else {
          emit(WorkoutTemplatesError(failure.message));
        }
        return false;
    }
  }

  Future<bool> remove(String templateId) async {
    if (_mutating) return false;
    final current = state;
    _mutating = true;
    if (current is WorkoutTemplatesLoaded) {
      emit(
        WorkoutTemplatesLoaded(
          current.items,
          current.pagination,
          mutating: true,
        ),
      );
    }
    final result = await _deleteTemplate(templateId);
    switch (result) {
      case ApiSuccess():
        _mutating = false;
        await load();
        return true;
      case ApiError(:final failure):
        _mutating = false;
        if (isClosed) return false;
        final now = state;
        if (now is WorkoutTemplatesLoaded) {
          emit(
            WorkoutTemplatesLoaded(
              now.items,
              now.pagination,
              mutationError: failure.message,
            ),
          );
        } else {
          emit(WorkoutTemplatesError(failure.message));
        }
        return false;
    }
  }
}
