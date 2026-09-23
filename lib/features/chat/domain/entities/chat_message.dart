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
}
