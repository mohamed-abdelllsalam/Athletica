/// Single-flight guard for global session-expired (401) handling.
///
/// When the auth token expires, the app typically has several authenticated
/// requests in flight at once (home, profile, plans, ...). Without a guard,
/// each 401 triggers its own SnackBar + navigation, so the user sees the
/// "Session expired" message 5-6 times queued in a row.
///
/// The guard lets exactly one 401 through per [cooldown] window; concurrent
/// or follow-up 401s inside the window are ignored (their errors still
/// propagate to repositories as [UnauthorizedFailure], but produce no global
/// UI). Pure Dart so it stays unit-testable without Flutter.
class SessionExpiredGuard {
  SessionExpiredGuard({Duration? cooldown})
      : cooldown = cooldown ?? const Duration(seconds: 5);

  final Duration cooldown;

  bool _handling = false;
  DateTime? _lastHandledAt;

  /// Returns true only for the first 401 in a burst. Must be called
  /// synchronously (before any `await`) so concurrent 401s see the flag.
  bool shouldHandle(DateTime now) {
    if (_handling) return false;
    final last = _lastHandledAt;
    if (last != null && now.difference(last) < cooldown) return false;
    _handling = true;
    _lastHandledAt = now;
    return true;
  }

  /// Releases the in-progress flag after [cooldown] so a genuinely new
  /// expiration (e.g. after re-login) is handled again.
  void complete() {
    Future.delayed(cooldown, () => _handling = false);
  }

  void resetForTest() {
    _handling = false;
    _lastHandledAt = null;
  }
}
