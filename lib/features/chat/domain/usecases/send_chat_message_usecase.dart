import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  const SendChatMessageUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<ChatMessage>> call({
    required String conversationId,
    required String content,
  }) =>
      _repository.sendMessage(conversationId: conversationId, content: content);
}
