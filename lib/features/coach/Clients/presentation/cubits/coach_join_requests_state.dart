import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';

sealed class CoachJoinRequestsState {
  const CoachJoinRequestsState();

  List<JoinRequest> get requests => const [];
}

final class CoachJoinRequestsInitial extends CoachJoinRequestsState {}

final class CoachJoinRequestsLoading extends CoachJoinRequestsState {}

final class CoachJoinRequestsLoaded extends CoachJoinRequestsState {
  const CoachJoinRequestsLoaded(this.requests);

  @override
  final List<JoinRequest> requests;
}

/// An accept/reject call is in flight for [actingRequestId].
final class CoachJoinRequestsActionInProgress extends CoachJoinRequestsState {
  const CoachJoinRequestsActionInProgress(this.requests, this.actingRequestId);

  @override
  final List<JoinRequest> requests;
  final String actingRequestId;
}

/// The last action failed — the list is kept so the user can retry.
final class CoachJoinRequestsActionError extends CoachJoinRequestsState {
  const CoachJoinRequestsActionError(this.requests, this.message);

  @override
  final List<JoinRequest> requests;
  final String message;
}

final class CoachJoinRequestsError extends CoachJoinRequestsState {
  const CoachJoinRequestsError(this.message);

  final String message;
}
