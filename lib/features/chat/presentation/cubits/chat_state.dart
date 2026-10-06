import 'package:athletica/features/chat/domain/entities/chat_message.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatFailureState extends ChatState {
  const ChatFailureState(this.message, {this.connectionError = false});
  final String message;
  final bool connectionError;
}

final class ChatReady extends ChatState {
  const ChatReady({
    required this.messages,
    required this.conversationId,
    required this.canSend,
    required this.hasMore,
    required this.isLoadingOlder,
    required this.isSending,
    required this.realtimeAvailable,
    this.errorMessage,
    this.uploadProgress,
    this.connectionError = false,
  });

  final List<ChatMessage> messages;
  final String? conversationId;
  final bool canSend;
  final bool hasMore;
  final bool isLoadingOlder;
  final bool isSending;
  final bool realtimeAvailable;
  final String? errorMessage;
  final double? uploadProgress;
  final bool connectionError;
}
