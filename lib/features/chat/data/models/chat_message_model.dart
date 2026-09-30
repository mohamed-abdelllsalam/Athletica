import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderUserId,
    required super.senderRole,
    required super.content,
    required super.createdAt,
    super.messageType,
    super.attachmentUrl,
    super.attachmentMime,
    super.attachmentSize,
    super.attachmentDurationSec,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderUserId: json['sender_user_id'] as String,
        senderRole: json['sender_role'] as String,
        content: json['content'] as String?,
        messageType: switch (json['message_type']) {
          'image' => MessageType.image,
          'voice' => MessageType.voice,
          null || 'text' => MessageType.text,
          _ => throw const FormatException('Unknown message type'),
        },
        attachmentUrl: json['attachment_url'] as String?,
        attachmentMime: json['attachment_mime'] as String?,
        attachmentSize: (json['attachment_size'] as num?)?.toInt(),
        attachmentDurationSec: (json['attachment_duration_sec'] as num?)
            ?.toInt(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
