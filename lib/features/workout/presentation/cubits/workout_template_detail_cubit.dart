import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/usecases/add_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/assign_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/create_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_template_detail_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/reorder_template_days_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_workout_template_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detail editor for one template: days + exercises + assign.
/// Every mutation returns the full template — the single source of truth
/// is replaced, never patched optimistically.
class WorkoutTemplateDetailCubit extends Cubit<WorkoutTemplateDetailState> {
  WorkoutTemplateDetailCubit(
    this._getDetail,
    this._updateTemplate,
    this._createDay,
    this._updateDay,
    this._deleteDay,
    this._reorderDays,
    this._addExercise,
    this._updateExercise,
    this._deleteExercise,
    this._assign,
  ) : super(const WorkoutTemplateDetailInitial());

  final GetWorkoutTemplateDetailUseCase _getDetail;
  final UpdateWorkoutTemplateUseCase _updateTemplate;
  final CreateTemplateDayUseCase _createDay;
  final UpdateTemplateDayUseCase _updateDay;
  final DeleteTemplateDayUseCase _deleteDay;
  final ReorderTemplateDaysUseCase _reorderDays;
  final AddTemplateExerciseUseCase _addExercise;
  final UpdateTemplateExerciseUseCase _updateExercise;
  final DeleteTemplateExerciseUseCase _deleteExercise;
  final AssignWorkoutTemplateUseCase _assign;

  String? _lastError;

  String? get lastError => _lastError;

  /// True once any mutation succeeds — the list screen uses it to refresh.
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  Future<void> load(String templateId) async {
    if (state is WorkoutTemplateDetailLoading) return;
    _hasChanges = false;
    emit(const WorkoutTemplateDetailLoading());
    final result = await _getDetail(templateId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutTemplateDetailLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutTemplateDetailError(failure.message));
    }
  }

  Future<bool> _mutate(
    Future<ApiResult<WorkoutTemplateEntry>> Function() run,
  ) async {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded || current.mutating) {
      return false;
    }
    _lastError = null;
    emit(WorkoutTemplateDetailLoaded(current.template, mutating: true));
    final result = await run();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return true;
        _hasChanges = true;
        emit(WorkoutTemplateDetailLoaded(data));
        return true;
      case ApiError(:final failure):
        if (isClosed) return false;
        _lastError = failure.message;
        emit(WorkoutTemplateDetailLoaded(current.template));
        return false;
    }
  }

  Future<bool> rename({String? title, String? description}) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(
      () => _updateTemplate(
        current.template.id,
        title: title,
        description: description,
      ),
    );
  }

  Future<bool> addDay(String title) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(() => _createDay(current.template.id, title: title));
  }

  Future<bool> editDay(
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
  }) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(
      () => _updateDay(
        current.template.id,
        dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
      ),
    );
  }

  Future<bool> removeDay(String dayId) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(() => _deleteDay(current.template.id, dayId));
  }

  Future<bool> reorderDays(List<String> dayIds) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(() => _reorderDays(current.template.id, dayIds));
  }

  Future<bool> addExercise(
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  }) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(
      () => _addExercise(
        current.template.id,
        dayId,
        exerciseId: exerciseId,
        exerciseOrder: exerciseOrder,
        notes: notes,
      ),
    );
  }

  Future<bool> editExercise(
    String dayId,
    String exerciseId, {
    int? exerciseOrder,
    String? notes,
  }) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(
      () => _updateExercise(
        current.template.id,
        dayId,
        exerciseId,
        exerciseOrder: exerciseOrder,
        notes: notes,
      ),
    );
  }

  Future<bool> removeExercise(String dayId, String exerciseId) {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded) return Future.value(false);
    return _mutate(
      () => _deleteExercise(current.template.id, dayId, exerciseId),
    );
  }

  /// Assigns to a client. Never sends start_date (server-generated).
  /// Returns the created plan id, or null on failure.
  Future<String?> assign({
    required String coachClientId,
    String? title,
    String? description,
  }) async {
    final current = state;
    if (current is! WorkoutTemplateDetailLoaded || current.mutating) {
      return null;
    }
    _lastError = null;
    emit(WorkoutTemplateDetailLoaded(current.template, mutating: true));
    final result = await _assign(
      current.template.id,
      coachClientId: coachClientId,
      title: title,
      description: description,
    );
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return null;
        emit(WorkoutTemplateDetailLoaded(current.template));
        return data.id;
      case ApiError(:final failure):
        if (isClosed) return null;
        _lastError = failure.message;
        emit(WorkoutTemplateDetailLoaded(current.template));
        return null;
    }
  }
}
