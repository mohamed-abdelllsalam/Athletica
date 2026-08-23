import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/assign_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/remove_assigned_client_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AssignPlanState {}

final class AssignPlanInitial extends AssignPlanState {}

final class AssignPlanClientsLoading extends AssignPlanState {}

final class AssignPlanClientsLoaded extends AssignPlanState {
  AssignPlanClientsLoaded(this.clients);

  final List<AssignedClient> clients;
}

final class AssignPlanClientsError extends AssignPlanState {
  AssignPlanClientsError(this.message);

  final String message;
}

final class AssignPlanAssigning extends AssignPlanState {
  AssignPlanAssigning(this.clients);

  final List<AssignedClient> clients;
}

final class AssignPlanSuccess extends AssignPlanState {}

final class AssignPlanError extends AssignPlanState {
  AssignPlanError(this.message, this.clients);

  final String message;
  final List<AssignedClient> clients;
}

class AssignPlanCubit extends Cubit<AssignPlanState> {
  AssignPlanCubit(
    this._getAssignedClients,
    this._assignTemplate,
    this._removeAssignedClient,
  ) : super(AssignPlanInitial());

  final GetAssignedClientsUseCase _getAssignedClients;
  final AssignNutritionTemplateUseCase _assignTemplate;
  final RemoveAssignedClientUseCase _removeAssignedClient;

  Future<void> loadClients() async {
    if (state is AssignPlanClientsLoading || state is AssignPlanAssigning) {
      return;
    }
    emit(AssignPlanClientsLoading());

    final result = await _getAssignedClients();
    switch (result) {
      case ApiSuccess(:final data):
        emit(AssignPlanClientsLoaded(data));
      case ApiError(:final failure):
        emit(AssignPlanClientsError(failure.message));
    }
  }

  /// [coachClientId] must be the `coach_clients.id` of the selected
  /// client relationship — not a user or client-profile id.
  Future<void> assign({
    required String templateId,
    required String coachClientId,
    required String title,
    required String description,
  }) async {
    final current = state;
    final clients = current is AssignPlanClientsLoaded
        ? current.clients
        : (current is AssignPlanAssigning ? current.clients : null);
    if (clients == null) return;

    emit(AssignPlanAssigning(clients));

    final result = await _assignTemplate(
      templateId,
      coachClientId: coachClientId,
      title: title,
      description: description,
    );
    switch (result) {
      case ApiSuccess():
        emit(AssignPlanSuccess());
      case ApiError(:final failure):
        emit(AssignPlanError(failure.message, clients));
    }
  }

  void resetToClients(List<AssignedClient> clients) {
    emit(AssignPlanClientsLoaded(clients));
  }

  /// Removes the coach-client relationship and reloads the roster.
  Future<void> removeClient(String coachClientId) async {
    final current = state;
    final clients = current is AssignPlanClientsLoaded
        ? current.clients
        : (current is AssignPlanAssigning ? current.clients : null);
    if (clients == null) return;

    emit(AssignPlanClientsLoading());

    final result = await _removeAssignedClient(coachClientId);
    switch (result) {
      case ApiSuccess():
        await loadClients();
      case ApiError(:final failure):
        emit(AssignPlanClientsError(failure.message));
    }
  }
}
