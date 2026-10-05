import 'dart:async';
import 'dart:convert';
import 'package:athletica/core/helper/app_navigator_key.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/core/services/chat_visibility_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/notifications/domain/usecases/get_notification_session.dart';
import 'package:athletica/features/notifications/domain/entities/notification_payload.dart';
import 'package:athletica/features/notifications/domain/usecases/device_lifecycle.dart';
import 'package:athletica/features/notifications/domain/usecases/notification_inbox.dart';
import 'package:athletica/features/notifications/domain/entities/inbox_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_router.dart';

@pragma('vm:entry-point')
Future<void> athleticaMessagingBackgroundHandler(RemoteMessage message) async {
  // The OS renders notification+data messages. Never show a second tray item.
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
}

class PushCoordinator with WidgetsBindingObserver {
  PushCoordinator(
    this.sessions,
    this.visibility,
    this.devices,
    this.router,
    this.getSession,
    this.inbox,
  );
  final GetNotificationSession getSession;
  final NotificationInbox inbox;
  final AuthSessionService sessions;
  final ChatVisibilityService visibility;
  final DeviceLifecycle devices;
  final NotificationRouter router;
  final _local = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<({NotificationPayload payload, String owner, String key})>
  _pending = [];
  final Set<String> _taps = {};
  final Set<String> _activeTaps = {};
  final Set<String> _received = {};
  bool _ready = false;
  bool _routing = false;
  bool _initialized = false;
  int _notificationId = 0;
  static const channel = AndroidNotificationChannel(
    'athletica_messages',
    'Athletica Messages',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized ||
        kIsWeb ||
        !{
          TargetPlatform.android,
          TargetPlatform.iOS,
        }.contains(defaultTargetPlatform)) {
      return;
    }
    _initialized = true;
    devices.setForeground(
      WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
    );
    WidgetsBinding.instance.addObserver(this);
    sessions.cleanup.add(devices.stop);
    sessions.cleanup.add(_clearDisplayed);
    _subscriptions.add(
      sessions.changes.listen((session) {
        visibility.resetSession();
        _ready = false;
        _pending.removeWhere((tap) => tap.owner != session?.userId);
        _taps.clear();
        _activeTaps.clear();
        _received.clear();
        if (session != null) devices.start(session.generation);
      }),
    );
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        athleticaMessagingBackgroundHandler,
      );
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) =>
            handleLocalTap(response.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      // Local rendering owns foreground presentation on both platforms.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
      _subscriptions.add(
        FirebaseMessaging.onMessage.listen(
          (message) => unawaited(_foreground(message)),
        ),
      );
      _subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => unawaited(handleRemoteTap(message)),
        ),
      );
      _subscriptions.add(
        FirebaseMessaging.instance.onTokenRefresh.listen(
          devices.requestRegistration,
        ),
      );
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) await handleRemoteTap(initial);
      final launch = await _local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        await handleLocalTap(launch?.notificationResponse?.payload);
      }
      unawaited(_requestPermission());
    } catch (_) {
      debugPrint('Push initialization unavailable; app remains usable.');
    }
  }

  Future<void> _requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      devices.requestRegistration();
    } catch (_) {
      debugPrint('Push initialization unavailable; app remains usable.');
    }
  }

  Future<void> _clearDisplayed() async {
    try {
      await _local.cancelAll();
    } catch (_) {
      debugPrint('Displayed notifications could not be cleared.');
    }
  }

  Future<NotificationSessionSnapshot?> _storedSession() async {
    final result = await getSession();
    return switch (result) {
      ApiSuccess<NotificationSessionSnapshot>(:final data) => data,
      ApiError<NotificationSessionSnapshot>() => null,
    };
  }

  Future<String?> _cachedOwner() async => (await _storedSession())?.owner;

  Future<bool> _belongsToCurrentLogin(RemoteMessage message) async =>
      (await _storedSession())?.allows(message.sentTime) ?? false;

  Future<void> handleRemoteTap(RemoteMessage message) async {
    try {
      final owner = sessions.current?.userId ?? await _cachedOwner();
      if (owner == null || !await _belongsToCurrentLogin(message)) return;
      _enqueue(message.data, owner, message.messageId);
    } catch (_) {
      debugPrint('Notification session could not be resolved.');
    }
  }

  /// Inbox, local and remote taps share validation, readiness and deduplication.
  void inboxTap(InboxNotification item, {required String owner}) {
    if (sessions.current?.userId != owner || item.type == 'chat_message') {
      return;
    }
    final payload = NotificationPayload.tryParse({
      ...item.data,
      'type': item.type,
      'notificationId': item.id,
    });
    if (payload == null || _activeTaps.contains(payload.tapKey)) return;
    // Inbox rows can reopen a dismissed destination; repeated remote/local
    // callbacks remain deduplicated by the handled-event set.
    _taps.remove(payload.tapKey);
    _enqueue(
      {...item.data, 'type': item.type, 'notificationId': item.id},
      owner,
      null,
    );
  }

  Future<void> handleLocalTap(String? value) async {
    try {
      if (value == null) return;
      final envelope = jsonDecode(value);
      if (envelope is! Map ||
          envelope['owner'] is! String ||
          envelope['data'] is! Map) {
        return;
      }
      final owner = sessions.current?.userId ?? await _cachedOwner();
      if (owner != envelope['owner']) return;
      _enqueue(
        Map<String, dynamic>.from(envelope['data'] as Map),
        owner!,
        envelope['key'] as String?,
      );
    } catch (_) {
      debugPrint('Invalid notification tap ignored.');
    }
  }

  void _enqueue(Map<String, dynamic> data, String owner, String? messageId) {
    final payload = NotificationPayload.tryParse(data);
    if (payload == null) return;
    final key = payload.notificationId != null
        ? payload.tapKey
        : messageId ?? payload.tapKey;
    if (_taps.contains(key) || _pending.any((tap) => tap.key == key)) return;
    if (_pending.length >= 20) _pending.removeAt(0);
    _pending.add((payload: payload, owner: owner, key: key));
    unawaited(_drain());
  }

  void navigatorReady(bool ready) {
    _ready = ready;
    if (ready) unawaited(_drain());
  }

  Future<void> _drain() async {
    if (_routing || !_ready || appNavigatorKey.currentState == null) return;
    _routing = true;
    try {
      while (_ready && _pending.isNotEmpty) {
        final session = sessions.current;
        if (session == null) return;
        final tap = _pending.removeAt(0);
        if (tap.owner != session.userId || !_taps.add(tap.key)) continue;
        if (_taps.length > 100) _taps.remove(_taps.first);
        final role = session.role == 'TRAINER' ? 'coach' : 'client';
        if (tap.payload.type.recipientRole != null &&
            tap.payload.type.recipientRole != role) {
          continue;
        }
        if (tap.payload.notificationId case final String id) {
          unawaited(inbox.markRead(id));
        }
        _activeTaps.add(tap.key);
        var dispatched = false;
        try {
          dispatched = await router.route(
            tap.payload,
            userId: session.userId,
            role: role,
            isSessionCurrent: () =>
                identical(sessions.current, session) && _ready,
            onClosed: () {
              if (identical(sessions.current, session)) {
                _activeTaps.remove(tap.key);
              }
            },
          );
        } finally {
          if (!dispatched) _activeTaps.remove(tap.key);
        }
      }
    } catch (_) {
      debugPrint('Notification destination unavailable.');
    } finally {
      _routing = false;
    }
  }

  Future<void> _foreground(RemoteMessage message) async {
    final session = sessions.current;
    final payload = NotificationPayload.tryParse(message.data);
    if (session != null &&
        payload != null &&
        payload.type != NotificationType.chatMessage) {
      unawaited(inbox.refreshBadge());
    }
    if (session == null || payload == null || message.notification == null) {
      return;
    }
    try {
      if (!await _belongsToCurrentLogin(message) ||
          !identical(sessions.current, session)) {
        return;
      }
    } catch (_) {
      debugPrint('Notification session could not be resolved.');
      return;
    }
    final role = session.role == 'TRAINER' ? 'coach' : 'client';
    if (payload.type.recipientRole != null &&
        payload.type.recipientRole != role) {
      return;
    }
    if (payload.conversationId != null &&
        payload.conversationId == visibility.visibleConversationId) {
      return;
    }
    final key = message.messageId ?? payload.tapKey;
    if (!_received.add(key)) return;
    if (_received.length > 100) _received.remove(_received.first);
    try {
      await _local.show(
        id: ++_notificationId,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'athletica_messages',
            'Athletica Messages',
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode({
          'owner': session.userId,
          'key': key,
          'data': message.data,
        }),
      );
    } catch (_) {
      debugPrint('Foreground notification could not be displayed.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    devices.setForeground(state == AppLifecycleState.resumed);
    if (state == AppLifecycleState.resumed) unawaited(inbox.refreshBadge());
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    sessions.cleanup.remove(devices.stop);
    sessions.cleanup.remove(_clearDisplayed);
    await devices.stop();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _pending.clear();
    _activeTaps.clear();
  }
}

class PushNavigatorObserver extends NavigatorObserver {
  PushNavigatorObserver(this.push);
  final PushCoordinator push;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _check(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _check(newRoute);
  void _check(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == 'coach-home') {
      final session = push.sessions.current;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (session != null &&
            identical(push.sessions.current, session) &&
            route?.isCurrent == true) {
          push.navigatorReady(true);
        }
      });
    }
  }
}
