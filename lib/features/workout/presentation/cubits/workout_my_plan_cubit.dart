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

  Future<void> loadActive() async {
    if (state is WorkoutMyPlanLoading) return;
    emit(const WorkoutMyPlanLoading());
    final result = await _getActive();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutMyPlanLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutMyPlanError(failure.message));
    }
  }

  Future<void> loadDetails(String planId) async {
    if (state is WorkoutMyPlanLoading) return;
    emit(const WorkoutMyPlanLoading());
    final result = await _getDetails(planId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutMyPlanDetailLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutMyPlanError(failure.message));
    }
  }
}

class WorkoutHistoryCubit extends Cubit<WorkoutHistoryState> {
  WorkoutHistoryCubit(this._getHistory)
      : super(const WorkoutHistoryInitial());

  final GetWorkoutHistoryUseCase _getHistory;

  Future<void> load() async {
    if (state is WorkoutHistoryLoading) return;
    emit(const WorkoutHistoryLoading());
    final result = await _getHistory();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutHistoryLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutHistoryError(failure.message));
    }
  }
}
