import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';

sealed class CoachClientsState {
  const CoachClientsState();

  List<CoachAssignedClient> get clients => const [];
}

final class CoachClientsInitial extends CoachClientsState {}

final class CoachClientsLoading extends CoachClientsState {}

final class CoachClientsLoaded extends CoachClientsState {
  const CoachClientsLoaded(this.clients);

  @override
  final List<CoachAssignedClient> clients;
}

/// A remove call is in flight for [removingRelationId].
final class CoachClientsActionInProgress extends CoachClientsState {
  const CoachClientsActionInProgress(this.clients, this.removingRelationId);

  @override
  final List<CoachAssignedClient> clients;
  final String removingRelationId;
}

/// The remove failed — the list is kept so the user can retry.
final class CoachClientsActionError extends CoachClientsState {
  const CoachClientsActionError(this.clients, this.message);

  @override
  final List<CoachAssignedClient> clients;
  final String message;
}

final class CoachClientsError extends CoachClientsState {
  const CoachClientsError(this.message);

  final String message;
}
