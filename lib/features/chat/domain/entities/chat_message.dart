class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderUserId;
  final String senderRole;
  final String content;
  final DateTime createdAt;

  bool isMine(String userId) => senderUserId == userId;

  static List<ChatMessage> chronological(Iterable<ChatMessage> messages) =>
      List<ChatMessage>.of(messages)..sort(compareChronologically);

  static int compareChronologically(ChatMessage a, ChatMessage b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime == 0 ? a.id.compareTo(b.id) : byTime;
  }
}
