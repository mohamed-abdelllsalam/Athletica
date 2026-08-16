import 'package:athletica/features/info/domain/entities/intake_answer.dart';

sealed class ProfileInfoState {
  const ProfileInfoState();
}

final class ProfileInfoInitial extends ProfileInfoState {
  const ProfileInfoInitial();
}

final class ProfileInfoLoading extends ProfileInfoState {
  const ProfileInfoLoading();
}

final class ProfileInfoLoaded extends ProfileInfoState {
  const ProfileInfoLoaded(this.answers);
  final List<IntakeAnswer> answers;
}

final class ProfileInfoError extends ProfileInfoState {
  const ProfileInfoError(this.message);
  final String message;
}
