sealed class AuthStatus {
  const AuthStatus();
}

final class Unauthenticated extends AuthStatus {
  const Unauthenticated();
}

final class ClientProfileIncomplete extends AuthStatus {
  const ClientProfileIncomplete();
}

final class CoachProfileIncomplete extends AuthStatus {
  const CoachProfileIncomplete();
}

final class ClientReady extends AuthStatus {
  const ClientReady();
}

final class CoachReady extends AuthStatus {
  const CoachReady();
}
