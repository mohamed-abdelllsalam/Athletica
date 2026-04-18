sealed class InfoState {
  const InfoState();
}

final class InfoInitial extends InfoState {
  const InfoInitial();
}

final class InfoLoading extends InfoState {
  const InfoLoading();
}

final class InfoSuccess extends InfoState {
  const InfoSuccess();
}

final class InfoError extends InfoState {
  final String message;
  const InfoError(this.message);
}
