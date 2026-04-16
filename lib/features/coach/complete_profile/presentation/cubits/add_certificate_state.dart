sealed class AddCertificateState {}

final class AddCertificateInitial extends AddCertificateState {}

final class AddCertificateSaving extends AddCertificateState {}

final class AddCertificateSuccess extends AddCertificateState {}

final class AddCertificateFailure extends AddCertificateState {
  AddCertificateFailure({required this.message});
  final String message;
}
