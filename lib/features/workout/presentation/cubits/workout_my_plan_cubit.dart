import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/usecases/get_my_workout_plan_details_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_my_workout_plan_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_history_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutMyPlanCubit extends Cubit<WorkoutMyPlanState> {
  WorkoutMyPlanCubit(this._getActive, this._getDetails)
    : super(const WorkoutMyPlanInitial());

  final GetMyWorkoutPlanUseCase _getActive;
  final GetMyWorkoutPlanDetailsUseCase _getDetails;

  bool _loading = false;
  WorkoutMyPlanState? _cached;
  String? _detailsId;

  void _fail(AppFailure failure) {
    if (failure is NetworkFailure && _cached != null) {
      final cached = _cached!;
      if (cached is WorkoutMyPlanDetailLoaded) {
        emit(WorkoutMyPlanDetailLoaded(cached.plan, isConnectionError: true));
        return;
      }
      if (cached is WorkoutMyPlanLoaded) {
        emit(WorkoutMyPlanLoaded(cached.plan, isConnectionError: true));
        return;
      }
    }
    emit(
      WorkoutMyPlanError(
        failure.message,
        isConnectionError: failure is NetworkFailure,
      ),
    );
  }

  Future<void> loadActive() async {
    if (_loading || isClosed) return;
    _loading = true;
    if (_cached == null) emit(const WorkoutMyPlanLoading());
    final result = await _getActive();
    _loading = false;
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        if (data == null) {
          _cached = const WorkoutMyPlanLoaded(null);
          _detailsId = null;
          emit(_cached!);
        } else {
          await loadDetails(data.id);
        }
      case ApiError(:final failure):
        if (isClosed) return;
        _fail(failure);
    }
  }

  Future<void> loadDetails(String planId) async {
    if (_loading || isClosed) return;
    _loading = true;
    if (_detailsId != null && _detailsId != planId) _cached = null;
    _detailsId = planId;
    if (_cached == null) emit(const WorkoutMyPlanLoading());
    final result = await _getDetails(planId);
    _loading = false;
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        _cached = WorkoutMyPlanDetailLoaded(data);
        emit(_cached!);
      case ApiError(:final failure):
        if (isClosed) return;
        _fail(failure);
    }
  }
}

class WorkoutHistoryCubit extends Cubit<WorkoutHistoryState> {
  WorkoutHistoryCubit(this._getHistory) : super(const WorkoutHistoryInitial());

  final GetWorkoutHistoryUseCase _getHistory;

  bool _loading = false;
  Future<void> load() async {
    if (_loading || isClosed) return;
    _loading = true;
    final current = state;
    if (current is! WorkoutHistoryLoaded) emit(const WorkoutHistoryLoading());
    final result = await _getHistory();
    _loading = false;
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutHistoryLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          failure is NetworkFailure && current is WorkoutHistoryLoaded
              ? WorkoutHistoryLoaded(current.days, isConnectionError: true)
              : WorkoutHistoryError(
                  failure.message,
                  isConnectionError: failure is NetworkFailure,
                ),
        );
    }
  }
}
