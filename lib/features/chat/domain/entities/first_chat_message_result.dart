import 'chat_message.dart';
import 'conversation.dart';

class FirstChatMessageResult {
  const FirstChatMessageResult({
    required this.conversation,
    required this.message,
  });

  final Conversation conversation;
  final ChatMessage message;
}
