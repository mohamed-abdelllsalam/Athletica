import 'chat_message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.coachClientId,
    required this.coachId,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.counterpart,
    this.lastMessage,
  });

  final String id;
  final String coachClientId;
  final String coachId;
  final String clientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final ConversationCounterpart? counterpart;
  final ChatMessage? lastMessage;
}

class ConversationCounterpart {
  const ConversationCounterpart({
    required this.role,
    this.id,
    this.username,
    this.profileImage,
  });

  final String role;
  final String? id;
  final String? username;
  final String? profileImage;
}
