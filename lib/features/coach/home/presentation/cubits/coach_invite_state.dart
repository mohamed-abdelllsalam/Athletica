sealed class CoachInviteState {}

final class CoachInviteInitial extends CoachInviteState {}

final class CoachInviteLoading extends CoachInviteState {}

final class CoachInviteSuccess extends CoachInviteState {
  CoachInviteSuccess(this.inviteLink);
  final String inviteLink;
}

final class CoachInviteError extends CoachInviteState {
  CoachInviteError(this.message);
  final String message;
}
