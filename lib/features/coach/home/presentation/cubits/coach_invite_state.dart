import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';

sealed class CoachInviteState {}

final class CoachInviteInitial extends CoachInviteState {}

final class CoachInviteLoading extends CoachInviteState {}

final class CoachInviteSuccess extends CoachInviteState {
  CoachInviteSuccess(this.invite);
  final CoachInviteCode invite;
}

final class CoachInviteRevoked extends CoachInviteState {}

final class CoachInviteError extends CoachInviteState {
  CoachInviteError(this.message);
  final String message;
}
