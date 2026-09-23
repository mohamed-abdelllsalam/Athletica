class Conversation {
  const Conversation({
    required this.id,
    required this.coachClientId,
    required this.coachId,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
  });

  final String id;
  final String coachClientId;
  final String coachId;
  final String clientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
}
