import 'package:athletica/features/chat/domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.coachClientId,
    required super.coachId,
    required super.clientId,
    required super.createdAt,
    required super.updatedAt,
    super.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] as String,
        coachClientId: json['coach_client_id'] as String,
        coachId: json['coach_id'] as String,
        clientId: json['client_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        lastMessageAt: json['last_message_at'] == null
            ? null
            : DateTime.parse(json['last_message_at'] as String),
      );
}
