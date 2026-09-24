import 'dart:async';

/// Signals persisted changes; contains no user data or cached completion state.
class CompletionChanges {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
  void notify() => _controller.add(null);
  Future<void> dispose() => _controller.close();
}
