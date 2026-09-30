import 'package:athletica/core/domain/entities/chat_attachment.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.messageType = MessageType.text,
    this.attachmentUrl,
    this.attachmentMime,
    this.attachmentSize,
    this.attachmentDurationSec,
  });

  final String id;
  final String conversationId;
  final String senderUserId;
  final String senderRole;
  final String? content;
  final MessageType messageType;
  final String? attachmentUrl;
  final String? attachmentMime;
  final int? attachmentSize;
  final int? attachmentDurationSec;
  String get previewText {
    final caption = content?.trim() ?? '';
    final label = switch (messageType) {
      MessageType.text => '',
      MessageType.image => 'Photo',
      MessageType.voice => 'Voice note',
    };
    return label.isEmpty
        ? caption
        : caption.isEmpty
        ? label
        : '$label: $caption';
  }

  final DateTime createdAt;

  bool isMine(String userId) => senderUserId == userId;

  static List<ChatMessage> chronological(Iterable<ChatMessage> messages) =>
      List<ChatMessage>.of(messages)..sort(compareChronologically);

  static int compareChronologically(ChatMessage a, ChatMessage b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime == 0 ? a.id.compareTo(b.id) : byTime;
  }
}
