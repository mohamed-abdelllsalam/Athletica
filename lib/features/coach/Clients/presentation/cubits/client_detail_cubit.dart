import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/domain/usecases/delete_client_nutrition_plan_usecase.dart';
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
  ClientDetailError(this.message);

  final String message;
}

class ClientDetailCubit extends Cubit<ClientDetailState> {
  ClientDetailCubit(
    this._getClientDetail,
    this._deleteNutritionPlan,
  ) : super(ClientDetailInitial());

  final GetClientDetailUseCase _getClientDetail;
  final DeleteClientNutritionPlanUseCase _deleteNutritionPlan;

  String? _currentClientId;

  Future<void> loadClientDetail(String clientId) async {
    if (state is ClientDetailLoading) return;
    _currentClientId = clientId;
    emit(ClientDetailLoading());

    final result = await _getClientDetail(clientId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(ClientDetailLoaded(data));
      case ApiError(:final failure):
        emit(ClientDetailError(failure.message));
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
        emit(ClientDetailError(failure.message));
    }
  }
}
