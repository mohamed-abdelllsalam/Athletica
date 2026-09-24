import 'package:athletica/features/chat/data/models/chat_message_model.dart';
import 'package:athletica/features/chat/domain/entities/chat_history_page.dart';

class ChatHistoryPageModel extends ChatHistoryPage {
  const ChatHistoryPageModel({
    required super.messages,
    required super.nextCursor,
    required super.hasMore,
  });

  factory ChatHistoryPageModel.fromJson(Map<String, dynamic> json) =>
      ChatHistoryPageModel(
        // Preserve backend order; history is documented newest-first.
        messages: (json['messages'] as List<dynamic>)
            .map(
              (item) => ChatMessageModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
        nextCursor: json['nextCursor'] as String?,
        hasMore: json['hasMore'] as bool,
      );
}
