import 'dart:async';

class AuthSession {
  const AuthSession(this.userId, this.role, this.generation);
  final String userId;
  final String role;
  final int generation;
}

/// Installation-wide session boundary, independent of widget/cubit lifetimes.
class AuthSessionService {
  final _changes = StreamController<AuthSession?>.broadcast(sync: true);
  AuthSession? current;
  int _generation = 0;
  Stream<AuthSession?> get changes => _changes.stream;
  final List<Future<void> Function()> cleanup = [];

  void start(String userId, String role) {
    if (current?.userId == userId && current?.role == role) return;
    current = AuthSession(userId, role, ++_generation);
    _changes.add(current);
  }

  Future<void> end() async {
    current = null;
    ++_generation;
    _changes.add(null);
    await Future.wait(
      cleanup.map((callback) async {
        try {
          await callback().timeout(const Duration(seconds: 10));
        } catch (_) {
          // Cleanup is best effort; session invalidation has already happened.
        }
      }),
    );
  }
}
