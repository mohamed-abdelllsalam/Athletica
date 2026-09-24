class WatchCompletionChangesUseCase {
  const WatchCompletionChangesUseCase(this._changes);
  final Stream<void> _changes;
  Stream<void> call() => _changes;
}
