import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/domain/usecases/assigned_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AssignedState {}

final class AssignedInitial extends AssignedState {}

final class AssignedLoading extends AssignedState {}

final class AssignedLoaded extends AssignedState {
  AssignedLoaded(this.assigned, {this.connectionError = false});

  final ClientAssigned assigned;
  final bool connectionError;
}

final class AssignedError extends AssignedState {
  AssignedError(this.message, {this.connectionError = false});

  final String message;
  final bool connectionError;
}

sealed class AssignActionState {}

final class AssignActionInitial extends AssignActionState {}

final class AssignActionLoading extends AssignActionState {}

final class AssignActionSuccess extends AssignActionState {
  AssignActionSuccess(this.assignType);

  final AssignType assignType;
}

final class AssignActionError extends AssignActionState {
  AssignActionError(this.message, this.assignType);

  final String message;
  final AssignType assignType;
}

enum AssignType { workout, nutrition }

class AssignedCubit extends Cubit<AssignedState> {
  AssignedCubit(this._getAssigned, this._assignWorkout, this._assignNutrition)
    : super(AssignedInitial());

  final GetAssignedPlansUseCase _getAssigned;
  final AssignClientWorkoutUseCase _assignWorkout;
  final AssignClientNutritionUseCase _assignNutrition;

  AssignActionState _actionState = AssignActionInitial();
  AssignActionState get actionState => _actionState;

  Future<void> loadAssigned() async {
    if (state is AssignedLoading) return;
    final previous = state;
    if (previous is! AssignedLoaded) emit(AssignedLoading());

    final result = await _getAssigned();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(AssignedLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        if (failure is NetworkFailure && previous is AssignedLoaded) {
          emit(AssignedLoaded(previous.assigned, connectionError: true));
        } else {
          emit(
            AssignedError(
              failure.message,
              connectionError: failure is NetworkFailure,
            ),
          );
        }
    }
  }

  Future<void> assignWorkout(String templateId) async {
    _actionState = AssignActionLoading();
    emit(_clamp());

    final result = await _assignWorkout(templateId);
    switch (result) {
      case ApiSuccess():
        _actionState = AssignActionSuccess(AssignType.workout);
        await loadAssigned();
      case ApiError(:final failure):
        _actionState = AssignActionError(failure.message, AssignType.workout);
        if (isClosed) return;
        emit(_clamp());
    }
  }

  Future<void> assignNutrition(String templateId) async {
    _actionState = AssignActionLoading();
    emit(_clamp());

    final result = await _assignNutrition(templateId);
    switch (result) {
      case ApiSuccess():
        _actionState = AssignActionSuccess(AssignType.nutrition);
        await loadAssigned();
      case ApiError(:final failure):
        _actionState = AssignActionError(failure.message, AssignType.nutrition);
        if (isClosed) return;
        emit(_clamp());
    }
  }

  void resetActionState() {
    _actionState = AssignActionInitial();
  }

  AssignedState _clamp() {
    final s = state;
    if (s is AssignedLoaded) return s;
    return AssignedLoading();
  }
}
