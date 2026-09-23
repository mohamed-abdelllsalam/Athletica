import 'package:athletica/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderUserId,
    required super.senderRole,
    required super.content,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderUserId: json['sender_user_id'] as String,
        senderRole: json['sender_role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
