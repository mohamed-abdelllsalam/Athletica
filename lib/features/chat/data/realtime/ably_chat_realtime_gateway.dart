import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/services/chat_visibility_service.dart';
import 'package:athletica/features/chat/data/models/chat_message_model.dart';
import 'package:athletica/features/chat/domain/realtime/chat_realtime_gateway.dart';
import 'package:dio/dio.dart';

class AblyChatRealtimeGateway implements ChatRealtimeGateway {
  AblyChatRealtimeGateway(this._dio, this._visibility);
  final Dio _dio;
  final ChatVisibilityService _visibility;

  ably.Realtime? _realtime;
  ably.RealtimeChannel? _channel;
  StreamSubscription<ably.Message>? _messageSubscription;
  StreamSubscription<ably.ConnectionStateChange>? _connectionSubscription;
  StreamSubscription<void>? _visibilitySubscription;
  Future<void> _presenceWork = Future<void>.value();
  int _generation = 0;

  void _syncPresence(ably.RealtimeChannel channel, String conversationId) {
    _presenceWork = _presenceWork.then((_) async {
      if (!identical(_channel, channel)) return;
      try {
        if (_visibility.visibleConversationId == conversationId) {
          // Identity is taken from the backend-issued authenticated Ably token.
          await channel.presence.enter().timeout(const Duration(seconds: 5));
        } else {
          await channel.presence.leave().timeout(const Duration(seconds: 5));
        }
      } catch (_) {
        // Presence failure must not interrupt messages. Retry on focus/reconnect.
      }
    });
  }

  @override
  Future<void> connect(
    String conversationId, {
    required void Function(ChatRealtimeEvent event) onEvent,
    required void Function(bool available) onAvailabilityChanged,
  }) async {
    final session = _visibility.sessionGeneration;
    await dispose();
    if (session != _visibility.sessionGeneration) return;
    final generation = _generation;
    final options = ably.ClientOptions()
      ..authCallback = (params) async {
        if (session != _visibility.sessionGeneration ||
            generation != _generation) {
          throw StateError('Chat session ended.');
        }
        final response = await _dio.get(
          ApiEndpoints.ablyToken,
          queryParameters: {'conversationId': conversationId},
        );
        final body = response.data as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        if (session != _visibility.sessionGeneration ||
            generation != _generation) {
          throw StateError('Chat session ended.');
        }
        return ably.TokenRequest.fromMap(
          Map<String, dynamic>.from(data['tokenRequest'] as Map),
        );
      };

    final realtime = ably.Realtime(options: options);
    _realtime = realtime;
    _connectionSubscription = realtime.connection.on().listen((change) {
      onAvailabilityChanged(change.current == ably.ConnectionState.connected);
      final channel = _channel;
      if (change.current == ably.ConnectionState.connected && channel != null) {
        _syncPresence(channel, conversationId);
      }
    });
    final channel = realtime.channels.get('conversation:$conversationId');
    _channel = channel;
    _visibilitySubscription = _visibility.changes.listen((_) {
      if (session != _visibility.sessionGeneration) {
        unawaited(dispose());
      } else {
        _syncPresence(channel, conversationId);
      }
    });
    await channel.attach();
    if (generation != _generation || !identical(_channel, channel)) return;
    _syncPresence(channel, conversationId);
    _messageSubscription = channel.subscribe(name: 'message.created').listen((
      event,
    ) {
      final raw = event.data;
      if (raw is! Map) return;
      final frame = Map<String, dynamic>.from(raw);
      final eventId = frame['id'];
      final rawPayload = frame['payload'];
      if (eventId is! String || rawPayload is! Map) return;
      final payload = Map<String, dynamic>.from(rawPayload);
      try {
        onEvent(
          ChatRealtimeEvent(
            eventId: eventId,
            message: ChatMessageModel.fromJson({
              'id': payload['messageId'],
              'conversation_id': payload['conversationId'],
              'sender_user_id': payload['senderUserId'],
              'sender_role': payload['senderRole'],
              'content': payload['content'],
              'message_type': payload['messageType'],
              'attachment_url': payload['attachmentUrl'],
              'attachment_mime': payload['attachmentMime'],
              'attachment_size': payload['attachmentSize'],
              'attachment_duration_sec': payload['attachmentDurationSec'],
              'created_at': payload['createdAt'],
            }),
          ),
        );
      } on Object {
        // Ignore malformed transport frames; REST history remains truth.
      }
    });
  }

  @override
  Future<void> dispose() async {
    _generation++;
    final channel = _channel;
    _channel = null;
    final realtime = _realtime;
    _realtime = null;
    final visibilitySubscription = _visibilitySubscription;
    _visibilitySubscription = null;
    final messageSubscription = _messageSubscription;
    _messageSubscription = null;
    final connectionSubscription = _connectionSubscription;
    _connectionSubscription = null;
    await visibilitySubscription?.cancel();
    await messageSubscription?.cancel();
    await connectionSubscription?.cancel();
    try {
      // Drain an in-flight enter before leaving, so it cannot restore presence.
      await _presenceWork;
      if (channel != null) {
        await channel.presence.leave().timeout(const Duration(seconds: 5));
        await channel.detach().timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // The channel may already be detached after a connection failure.
    }
    realtime?.close();
  }
}
