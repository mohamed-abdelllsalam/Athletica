import 'package:athletica/features/chat/data/models/chat_message_model.dart';
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
    super.counterpart,
    super.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final counterpartJson = _optionalObject(json['counterpart'], 'counterpart');
    final lastMessageJson = _optionalObject(
      json['last_message'],
      'last_message',
    );
    return ConversationModel(
      id: json['id'] as String,
      coachClientId: json['coach_client_id'] as String,
      coachId: json['coach_id'] as String,
      clientId: json['client_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      counterpart: counterpartJson == null
          ? null
          : ConversationCounterpart(
              role: counterpartJson['role'] as String,
              id: counterpartJson['id'] as String?,
              username: counterpartJson['username'] as String?,
              profileImage: counterpartJson['profile_image'] as String?,
            ),
      lastMessage: lastMessageJson == null
          ? null
          : ChatMessageModel.fromJson(lastMessageJson),
    );
  }

  static Map<String, dynamic>? _optionalObject(Object? value, String field) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('Expected $field to be an object or null.');
  }
}
