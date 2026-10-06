import 'dart:async';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'device_usecases.dart';
import '../entities/device_registration.dart';

/// Single-flight device work. Session generations fence every asynchronous step.
class DeviceLifecycle {
  DeviceLifecycle({
    required this.register,
    required this.heartbeat,
    required this.cancel,
    required this.deviceId,
    required this.token,
    required this.platform,
    required this.report,
    this.onRegistered,
  });
  final RegisterDevice register;
  final HeartbeatDevice heartbeat;
  final CancelDeviceWork cancel;
  final Future<String> Function() deviceId;
  final Future<String?> Function() token;
  final String platform;
  final void Function(AppFailure) report;
  final void Function(DeviceRegistration)? onRegistered;
  int? _session;
  bool _foreground = true;
  Timer? _timer;
  Timer? _retry;
  Future<void>? _running;
  bool _again = false;
  int _attempts = 0;
  String? _freshToken;
  bool _heartbeatRecoveryUsed = false;
  bool _registrationSuspended = false;
  bool _conflictRetried = false;

  void start(int generation) {
    _session = generation;
    _attempts = 0;
    _freshToken = null;
    _heartbeatRecoveryUsed = false;
    _registrationSuspended = false;
    _conflictRetried = false;
    _schedule();
    requestRegistration();
  }

  bool _current(int generation) => _session == generation && _foreground;

  void setForeground(bool value) {
    _foreground = value;
    _timer?.cancel();
    _retry?.cancel();
    if (value && _session != null) {
      _attempts = 0;
      _schedule();
      requestRegistration();
    }
  }

  void _schedule() {
    _timer?.cancel();
    if (!_foreground || _session == null) return;
    _timer = Timer.periodic(const Duration(minutes: 20), (_) => _launch(false));
  }

  void requestRegistration([String? refreshedToken]) {
    if (_session == null) return;
    if (refreshedToken != null) _freshToken = refreshedToken;
    _launch(true);
  }

  void _launch(bool registration) {
    final session = _session;
    if (session == null || !_foreground || _registrationSuspended) return;
    if (_running != null) {
      _again = _again || registration;
      return;
    }
    _running = _work(session, registration).whenComplete(() {
      _running = null;
      if (_again) {
        _again = false;
        _launch(true);
      }
    });
  }

  Future<void> _work(int generation, bool registration) async {
    try {
      final id = await deviceId().timeout(const Duration(seconds: 5));
      if (!_current(generation)) return;
      if (!registration) {
        final result = await heartbeat(id, generation);
        if (!_current(generation)) return;
        switch (result) {
          case ApiSuccess<bool>(data: true):
            return;
          case ApiSuccess<bool>(data: false):
            if (_heartbeatRecoveryUsed) {
              _registrationSuspended = true;
              _timer?.cancel();
              _retry?.cancel();
              report(
                const ServerFailure(
                  'Push installation was displaced again; registration is paused until the next login.',
                ),
              );
              return;
            }
            _heartbeatRecoveryUsed = true;
            registration = true;
          case ApiError<bool>(:final failure):
            _failed(generation, failure);
            return;
        }
      }
      final refreshed = _freshToken;
      _freshToken = null;
      final fcmToken =
          refreshed ?? await token().timeout(const Duration(seconds: 8));
      if (!_current(generation)) return;
      if (fcmToken == null || fcmToken.isEmpty) {
        _failed(generation, const NetworkFailure('Push token is not ready.'));
        return;
      }
      final result = await register(fcmToken, platform, id, generation);
      if (!_current(generation)) return;
      switch (result) {
        case ApiSuccess<DeviceRegistration>(:final data):
          _attempts = 0;
          _retry?.cancel();
          onRegistered?.call(data);
        case ApiError<DeviceRegistration>(:final failure):
          _failed(generation, failure);
      }
    } catch (_) {
      if (_current(generation)) {
        _failed(
          generation,
          const NetworkFailure('Push setup temporarily unavailable.'),
        );
      }
    }
  }

  void _failed(int generation, AppFailure failure) {
    report(failure);
    if (failure is DeviceConflictFailure) {
      if (_conflictRetried) return;
      _conflictRetried = true;
      _retry?.cancel();
      _retry = Timer(const Duration(seconds: 1), () {
        if (_current(generation)) _launch(true);
      });
      return;
    }
    final retryable =
        failure is NetworkFailure ||
        (failure is ServerFailure && failure.retryable);
    if (!retryable || _attempts >= 3) return;
    _retry?.cancel();
    _retry = Timer(Duration(seconds: 5 * (1 << _attempts++)), () {
      if (_current(generation)) _launch(true);
    });
  }

  Future<void> stop() async {
    _session = null;
    _freshToken = null;
    _again = false;
    _timer?.cancel();
    _retry?.cancel();
    try {
      // Drain an accepted registration before server logout removes its row.
      // Cancellation alone cannot undo a request already accepted by the server.
      await _running?.timeout(const Duration(seconds: 8));
    } catch (_) {
      report(
        const ServerFailure(
          'Push cleanup timed out; server cleanup may be required.',
        ),
      );
    } finally {
      cancel();
    }
  }
}
