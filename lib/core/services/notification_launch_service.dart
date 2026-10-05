import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Recovers Android's original timestamp when Firebase reconstructs a saved
/// notification without its sent time after the app process has exited.
class NotificationLaunchService {
  const NotificationLaunchService();

  static const _channel = MethodChannel('athletica/notification_launch');

  Future<DateTime?> resolveSentTime({
    required String? messageId,
    required DateTime? sentTime,
  }) async {
    if (sentTime != null && sentTime.millisecondsSinceEpoch > 0) {
      return sentTime;
    }
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        messageId == null ||
        messageId.isEmpty) {
      return null;
    }
    try {
      final timestamp = await _channel.invokeMethod<int>('getSentTime', {
        'messageId': messageId,
      });
      return timestamp != null && timestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } on PlatformException {
      debugPrint('Notification launch timestamp unavailable.');
      return null;
    } on MissingPluginException {
      debugPrint('Notification launch timestamp unavailable.');
      return null;
    }
  }
}
