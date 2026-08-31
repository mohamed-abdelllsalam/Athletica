import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';

sealed class CoachProfileState {
  const CoachProfileState();
}

final class CoachProfileInitial extends CoachProfileState {
  const CoachProfileInitial();
}

final class CoachProfileLoading extends CoachProfileState {
  const CoachProfileLoading();
}

final class CoachProfileLoaded extends CoachProfileState {
  const CoachProfileLoaded(this.profile);

  final CoachProfileEntity profile;
}

final class CoachProfileUpdating extends CoachProfileState {
  const CoachProfileUpdating(this.profile);

  final CoachProfileEntity profile;
}

final class CoachProfileError extends CoachProfileState {
  const CoachProfileError(this.message, {this.profile});

  final String message;
  final CoachProfileEntity? profile;
}

final class CoachProfileImageUploading extends CoachProfileState {
  const CoachProfileImageUploading(this.profile);

  final CoachProfileEntity profile;
}

final class CoachProfileImageUploaded extends CoachProfileState {
  const CoachProfileImageUploaded(this.profile);

  final CoachProfileEntity profile;
}

final class CoachProfileImageDeleted extends CoachProfileState {
  const CoachProfileImageDeleted(this.profile);

  final CoachProfileEntity profile;
}
