import 'package:athletica/features/profile/domain/entities/client_profile_entity.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.profile);
  final ClientProfileEntity profile;
}

final class ProfileError extends ProfileState {
  ProfileError(this.message);
  final String message;
}