import 'dart:async';

import 'package:athletica/features/chat/domain/entities/chat_message.dart';

class ChatRealtimeEvent {
  const ChatRealtimeEvent({required this.eventId, required this.message});
  final String eventId;
  final ChatMessage message;
}

abstract interface class ChatRealtimeGateway {
  Future<void> connect(
    String conversationId, {
    required void Function(ChatRealtimeEvent event) onEvent,
    required void Function(bool available) onAvailabilityChanged,
  });

  Future<void> dispose();
}
