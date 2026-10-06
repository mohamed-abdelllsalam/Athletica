import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/domain/usecases/delete_client_nutrition_plan_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/delete_client_workout_plan_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_client_detail_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ClientDetailState {}

final class ClientDetailInitial extends ClientDetailState {}

final class ClientDetailLoading extends ClientDetailState {}

final class ClientDetailLoaded extends ClientDetailState {
  ClientDetailLoaded(this.detail);

  final ClientDetail detail;
}

final class ClientDetailError extends ClientDetailState {
  ClientDetailError(
    this.message, {
    this.detail,
    this.isConnectionError = false,
  });

  final String message;
  final ClientDetail? detail;
  final bool isConnectionError;
}

class ClientDetailCubit extends Cubit<ClientDetailState> {
  ClientDetailCubit(
    this._getClientDetail,
    this._deleteNutritionPlan,
    this._deleteWorkoutPlan,
  ) : super(ClientDetailInitial());

  final GetClientDetailUseCase _getClientDetail;
  final DeleteClientNutritionPlanUseCase _deleteNutritionPlan;
  final DeleteClientWorkoutPlanUseCase _deleteWorkoutPlan;

  String? _currentClientId;

  Future<void> loadClientDetail(String clientId) async {
    if (state is ClientDetailLoading) return;
    final previous = _currentClientId == clientId
        ? switch (state) {
            ClientDetailLoaded(:final detail) => detail,
            ClientDetailError(:final detail) => detail,
            _ => null,
          }
        : null;
    _currentClientId = clientId;
    if (previous == null) emit(ClientDetailLoading());

    final result = await _getClientDetail(clientId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(ClientDetailLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          ClientDetailError(
            failure.message,
            detail: failure is NetworkFailure ? previous : null,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> deleteNutritionPlan(String planId) async {
    final current = state;
    if (current is! ClientDetailLoaded) return;

    final result = await _deleteNutritionPlan(planId);
    switch (result) {
      case ApiSuccess():
        if (_currentClientId != null) {
          await loadClientDetail(_currentClientId!);
        }
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          ClientDetailError(
            failure.message,
            detail: failure is NetworkFailure ? current.detail : null,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> deleteWorkoutPlan(String planId) async {
    final current = state;
    if (current is! ClientDetailLoaded) return;

    final result = await _deleteWorkoutPlan(planId);
    switch (result) {
      case ApiSuccess():
        if (_currentClientId != null) {
          await loadClientDetail(_currentClientId!);
        }
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          ClientDetailError(
            failure.message,
            detail: failure is NetworkFailure ? current.detail : null,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }
}
