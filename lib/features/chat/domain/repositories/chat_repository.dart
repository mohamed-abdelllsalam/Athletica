import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/chat_history_page.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/entities/first_chat_message_result.dart';

abstract interface class ChatRepository {
  Future<ApiResult<List<Conversation>>> getConversations({int limit = 50});

  Future<ApiResult<ChatHistoryPage>> getHistory({
    required String conversationId,
    String? before,
    int limit = 50,
  });

  Future<ApiResult<ChatMessage>> sendMessage({
    required String conversationId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  });

  Future<ApiResult<FirstChatMessageResult>> sendFirstMessage({
    required String coachClientId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  });
}
