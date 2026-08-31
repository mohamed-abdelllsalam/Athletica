import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.profile);
  final ClientProfileEntity profile;
}

final class ProfileUpdating extends ProfileState {
  ProfileUpdating(this.profile);
  final ClientProfileEntity profile;
}

final class ProfileError extends ProfileState {
  ProfileError(this.message, {this.profile});
  final String message;
  final ClientProfileEntity? profile;
}

final class ProfileImageUploading extends ProfileState {
  ProfileImageUploading(this.profile);
  final ClientProfileEntity profile;
}

final class ProfileImageUploaded extends ProfileState {
  ProfileImageUploaded(this.profile);
  final ClientProfileEntity profile;
}

final class ProfileImageDeleted extends ProfileState {
  ProfileImageDeleted(this.profile);
  final ClientProfileEntity profile;
}
