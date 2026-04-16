sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
