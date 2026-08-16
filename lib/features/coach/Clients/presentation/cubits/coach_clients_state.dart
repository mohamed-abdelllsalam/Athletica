import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

sealed class CoachClientsState {}

final class CoachClientsInitial extends CoachClientsState {}

final class CoachClientsLoading extends CoachClientsState {}

final class CoachClientsLoaded extends CoachClientsState {
  CoachClientsLoaded(this.clients);
  final List<CoachClient> clients;
}

final class CoachClientsError extends CoachClientsState {
  CoachClientsError(this.message);
  final String message;
}
