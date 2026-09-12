import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/usecases/delete_workout_plan_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_plan_detail_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_plans_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/manage_plan_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/manage_plan_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_plan_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_workout_plan_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutPlansCubit extends Cubit<WorkoutPlansState> {
  WorkoutPlansCubit(this._getPlans) : super(const WorkoutPlansInitial());

  final GetWorkoutPlansUseCase _getPlans;

  Future<void> load({
    required String clientId,
    bool? isActive = true,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (state is WorkoutPlansLoading) return;
    emit(const WorkoutPlansLoading());
    final result = await _getPlans(
      clientId: clientId,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutPlansLoaded(data.items, data.pagination));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutPlansError(failure.message));
    }
  }
}

/// Detail editor for one assigned plan (coach): sets/reps live here.
class WorkoutPlanDetailCubit extends Cubit<WorkoutPlanDetailState> {
  WorkoutPlanDetailCubit(
    this._getDetail,
    this._updatePlan,
    this._deletePlan,
    this._days,
    this._updateExercise,
    this._exercises,
  ) : super(const WorkoutPlanDetailInitial());

  final GetWorkoutPlanDetailUseCase _getDetail;
  final UpdateWorkoutPlanUseCase _updatePlan;
  final DeleteWorkoutPlanUseCase _deletePlan;
  final ManagePlanDayUseCase _days;
  final UpdatePlanExerciseUseCase _updateExercise;
  final ManagePlanExerciseUseCase _exercises;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> load(String planId) async {
    if (state is WorkoutPlanDetailLoading) return;
    emit(const WorkoutPlanDetailLoading());
    final result = await _getDetail(planId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutPlanDetailLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutPlanDetailError(failure.message));
    }
  }

  Future<bool> _mutate(
    Future<ApiResult<WorkoutPlanEntry>> Function() run,
  ) async {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded || current.mutating) return false;
    _lastError = null;
    emit(WorkoutPlanDetailLoaded(current.plan, mutating: true));
    final result = await run();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return true;
        emit(WorkoutPlanDetailLoaded(data));
        return true;
      case ApiError(:final failure):
        if (isClosed) return false;
        _lastError = failure.message;
        emit(WorkoutPlanDetailLoaded(current.plan));
        return false;
    }
  }

  Future<bool> rename({String? title, String? description}) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(
      () => _updatePlan(current.plan.id, title: title, description: description),
    );
  }

  Future<bool> remove() async {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded || current.mutating) return false;
    _lastError = null;
    emit(WorkoutPlanDetailLoaded(current.plan, mutating: true));
    final result = await _deletePlan(current.plan.id);
    switch (result) {
      case ApiSuccess():
        // Caller should pop; keep last known plan visible meanwhile.
        if (isClosed) return true;
        emit(WorkoutPlanDetailLoaded(current.plan));
        return true;
      case ApiError(:final failure):
        if (isClosed) return false;
        _lastError = failure.message;
        emit(WorkoutPlanDetailLoaded(current.plan));
        return false;
    }
  }

  /// Coach fills the prescription after assignment (sets/reps/rest_time).
  Future<bool> setSetsReps(
    String dayId,
    String exerciseId, {
    int? sets,
    int? reps,
    int? restTime,
  }) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(
      () => _updateExercise(
        current.plan.id,
        dayId,
        exerciseId,
        sets: sets,
        reps: reps,
        restTime: restTime,
      ),
    );
  }

  Future<bool> addExercise(
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(
      () => _exercises.add(
        current.plan.id,
        dayId,
        exerciseId: exerciseId,
        orderNumber: orderNumber,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
      ),
    );
  }

  Future<bool> removeExercise(String dayId, String exerciseId) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(
      () => _exercises.delete(current.plan.id, dayId, exerciseId),
    );
  }

  Future<bool> addDay(String title, {String? note}) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(() => _days.create(current.plan.id, title, note: note));
  }

  Future<bool> editDay(
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(
      () => _days.update(
        current.plan.id,
        dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
        note: note,
      ),
    );
  }

  Future<bool> removeDay(String dayId) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(() => _days.delete(current.plan.id, dayId));
  }

  Future<bool> reorderDays(List<String> dayIds) {
    final current = state;
    if (current is! WorkoutPlanDetailLoaded) return Future.value(false);
    return _mutate(() => _days.reorder(current.plan.id, dayIds));
  }
}
