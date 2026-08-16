import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';

sealed class CoachProfileState {}

final class CoachProfileInitial extends CoachProfileState {}

final class CoachProfileLoading extends CoachProfileState {}

final class CoachProfileLoaded extends CoachProfileState {
  CoachProfileLoaded(this.profile);
  final CoachProfileEntity profile;
}

final class CoachProfileError extends CoachProfileState {
  CoachProfileError(this.message);
  final String message;
}
