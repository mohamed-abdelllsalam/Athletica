sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class DeviceConflictFailure extends AppFailure {
  const DeviceConflictFailure() : super('Device registration conflict.');
}

final class InboxNotFoundFailure extends AppFailure {
  const InboxNotFoundFailure() : super('Notification is no longer available.');
}

final class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.retryable = false});

  final bool retryable;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(super.message);
}

final class GoogleRoleRequiredFailure extends AppFailure {
  const GoogleRoleRequiredFailure()
    : super('Choose whether you want to continue as a coach or client.');
}

final class GoogleIdTokenRequiredFailure extends AppFailure {
  const GoogleIdTokenRequiredFailure()
    : super('Google did not provide a valid ID token. Please sign in again.');
}

final class GoogleInvalidTokenFailure extends AppFailure {
  const GoogleInvalidTokenFailure()
    : super('Google sign-in expired. Please try again.');
}

final class EmailNotVerifiedFailure extends AppFailure {
  const EmailNotVerifiedFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}

final class CertificateValidationFailure extends AppFailure {
  const CertificateValidationFailure(super.message);
}

/// Client check-in submit answered with 403: the one-shot pending assignment
/// was already consumed (`checkin_no_pending_assignment`). Presentation
/// refetches pending state + history on this, instead of message-matching.
final class CheckinNoPendingFailure extends AppFailure {
  const CheckinNoPendingFailure(super.message);
}

final class ChatFailure extends AppFailure {
  const ChatFailure(super.message, {this.statusCode});
  final int? statusCode;
}
