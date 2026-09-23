import 'chat_message.dart';

class ChatHistoryPage {
  const ChatHistoryPage({
    required this.messages,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool hasMore;
}
