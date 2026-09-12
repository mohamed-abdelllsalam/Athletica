import 'package:athletica/core/network/session_expired_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionExpiredGuard', () {
    test('burst of 6 concurrent 401s is handled only once', () {
      final guard = SessionExpiredGuard();
      final now = DateTime(2026, 9, 12);
      // Reproduces the reported bug: dashboard fires ~6 authenticated
      // requests at once, all fail with 401 at the same instant.
      final results = List.generate(6, (_) => guard.shouldHandle(now));
      expect(results.where((handled) => handled), hasLength(1));
    });

    test('follow-up 401 inside the cooldown window is ignored', () {
      final guard = SessionExpiredGuard();
      final now = DateTime(2026, 9, 12);
      expect(guard.shouldHandle(now), isTrue);
      expect(
        guard.shouldHandle(now.add(const Duration(seconds: 1))),
        isFalse,
      );
    });

    test('a fresh expiration after the cooldown is handled again', () {
      final guard = SessionExpiredGuard(
        cooldown: const Duration(seconds: 5),
      );
      final now = DateTime(2026, 9, 12);
      expect(guard.shouldHandle(now), isTrue);
      expect(
        guard.shouldHandle(now.add(const Duration(seconds: 6))),
        isFalse,
        reason: 'in-progress flag is only released by complete()',
      );
      guard.resetForTest();
      expect(
        guard.shouldHandle(now.add(const Duration(seconds: 6))),
        isTrue,
      );
    });
  });
}
