import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';

sealed class AddCertificateState {
  const AddCertificateState();
}

final class AddCertificateInitial extends AddCertificateState {
  const AddCertificateInitial();
}

final class AddCertificateSaving extends AddCertificateState {
  const AddCertificateSaving();
}

final class AddCertificateSuccess extends AddCertificateState {
  const AddCertificateSuccess(this.achievement);

  final CoachAchievement achievement;
}

final class AddCertificateFailure extends AddCertificateState {
  const AddCertificateFailure(this.message);

  final String message;
}
