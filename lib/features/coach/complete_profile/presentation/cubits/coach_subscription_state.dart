sealed class CoachSubscriptionState {
  const CoachSubscriptionState();
}

final class CoachSubscriptionInitial extends CoachSubscriptionState {
  const CoachSubscriptionInitial();
}

final class CoachSubscriptionLoading extends CoachSubscriptionState {
  const CoachSubscriptionLoading();
}

final class CoachSubscriptionSuccess extends CoachSubscriptionState {
  const CoachSubscriptionSuccess();
}

final class CoachSubscriptionError extends CoachSubscriptionState {
  final String message;
  const CoachSubscriptionError(this.message);
}
