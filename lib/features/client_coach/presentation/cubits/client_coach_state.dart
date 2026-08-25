import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';

sealed class ClientCoachState {
  const ClientCoachState();
}

final class ClientCoachInitial extends ClientCoachState {
  const ClientCoachInitial();
}

final class ClientCoachLoading extends ClientCoachState {
  const ClientCoachLoading();
}

/// A coach is assigned.
final class ClientCoachLoaded extends ClientCoachState {
  const ClientCoachLoaded(this.coach);

  final AssignedCoach coach;
}

/// No coach assigned — the join form is shown.
final class ClientCoachNoCoach extends ClientCoachState {
  const ClientCoachNoCoach();
}

/// Token submit is in flight.
final class ClientCoachSubmitting extends ClientCoachState {
  const ClientCoachSubmitting();
}

/// Invite token accepted by the API; waiting for the coach to accept.
final class ClientCoachRequestSent extends ClientCoachState {
  const ClientCoachRequestSent(this.requestStatus, {this.coachName = ''});

  final String requestStatus;

  /// Best-effort coach display name; empty when the API omits it.
  final String coachName;
}

final class ClientCoachError extends ClientCoachState {
  const ClientCoachError(this.message);

  final String message;
}
