sealed class RestTimerState {
  const RestTimerState({required this.remaining, required this.total});
  final Duration remaining;
  final Duration total;
}

class RestTimerRunning extends RestTimerState {
  const RestTimerRunning({required super.remaining, required super.total});
}

class RestTimerPaused extends RestTimerState {
  const RestTimerPaused({required super.remaining, required super.total});
}

class RestTimerDone extends RestTimerState {
  const RestTimerDone({required super.total}) : super(remaining: Duration.zero);
}
