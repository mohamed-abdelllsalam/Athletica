sealed class CompleteProfileState {
  const CompleteProfileState();
}

final class CompleteProfileInitial extends CompleteProfileState {
  const CompleteProfileInitial();
}

final class CompleteProfileLoading extends CompleteProfileState {
  const CompleteProfileLoading();
}

final class CompleteProfileSuccess extends CompleteProfileState {
  const CompleteProfileSuccess();
}

final class CompleteProfileError extends CompleteProfileState {
  final String message;
  const CompleteProfileError(this.message);
}
