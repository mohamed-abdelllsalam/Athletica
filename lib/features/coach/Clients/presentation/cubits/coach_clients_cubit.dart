import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/remove_coach_assigned_client_usecase.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachClientsCubit extends Cubit<CoachClientsState> {
  CoachClientsCubit(this._getAssignedClients, this._removeAssignedClient)
      : super(CoachClientsInitial());

  final GetCoachAssignedClientsUseCase _getAssignedClients;
  final RemoveCoachAssignedClientUseCase _removeAssignedClient;

  Future<void> loadClients() async {
    if (state is CoachClientsLoading) return;

    emit(CoachClientsLoading());

    final result = await _getAssignedClients();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(CoachClientsLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachClientsError(failure.message));
    }
  }

  /// Removes [client] from the roster.
  ///
  /// The API expects the **client profile id** in the DELETE path (verified
  /// against the live backend), not the roster relation id.
  Future<void> removeClient(CoachAssignedClient client) async {
    final clients = state.clients;
    if (state is CoachClientsActionInProgress) return;
    if (client.clientId.isEmpty) return;

    emit(CoachClientsActionInProgress(clients, client.relationId));

    final result = await _removeAssignedClient(client.clientId);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(
          CoachClientsLoaded(
            clients.where((c) => c.relationId != client.relationId).toList(),
          ),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachClientsActionError(clients, failure.message));
    }
  }
}
