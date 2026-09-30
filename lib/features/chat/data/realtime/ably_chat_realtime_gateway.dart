import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/chat/data/models/chat_message_model.dart';
import 'package:athletica/features/chat/domain/realtime/chat_realtime_gateway.dart';
import 'package:dio/dio.dart';

class AblyChatRealtimeGateway implements ChatRealtimeGateway {
  AblyChatRealtimeGateway(this._dio);
  final Dio _dio;

  ably.Realtime? _realtime;
  ably.RealtimeChannel? _channel;
  StreamSubscription<ably.Message>? _messageSubscription;
  StreamSubscription<ably.ConnectionStateChange>? _connectionSubscription;

  @override
  Future<void> connect(
    String conversationId, {
    required void Function(ChatRealtimeEvent event) onEvent,
    required void Function(bool available) onAvailabilityChanged,
  }) async {
    await dispose();
    final options = ably.ClientOptions()
      ..authCallback = (params) async {
        final response = await _dio.get(
          ApiEndpoints.ablyToken,
          queryParameters: {'conversationId': conversationId},
        );
        final body = response.data as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        return ably.TokenRequest.fromMap(
          Map<String, dynamic>.from(data['tokenRequest'] as Map),
        );
      };

    final realtime = ably.Realtime(options: options);
    _realtime = realtime;
    _connectionSubscription = realtime.connection.on().listen((change) {
      onAvailabilityChanged(change.current == ably.ConnectionState.connected);
    });
    final channel = realtime.channels.get('conversation:$conversationId');
    _channel = channel;
    await channel.attach();
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
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    try {
      await _channel?.detach();
    } catch (_) {
      // The channel may already be detached after a connection failure.
    }
    _channel = null;
    _realtime?.close();
    _realtime = null;
  }
}
