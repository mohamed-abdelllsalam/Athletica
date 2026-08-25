import 'package:athletica/core/utils/api_result.dart';
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
        emit(CoachClientsLoaded(data));
      case ApiError(:final failure):
        emit(CoachClientsError(failure.message));
    }
  }

  Future<void> removeClient(String relationId) async {
    final clients = state.clients;
    if (state is CoachClientsActionInProgress) return;
    if (relationId.isEmpty) return;

    emit(CoachClientsActionInProgress(clients, relationId));

    final result = await _removeAssignedClient(relationId);
    switch (result) {
      case ApiSuccess():
        emit(
          CoachClientsLoaded(
            clients.where((c) => c.relationId != relationId).toList(),
          ),
        );
      case ApiError(:final failure):
        emit(CoachClientsActionError(clients, failure.message));
    }
  }
}
