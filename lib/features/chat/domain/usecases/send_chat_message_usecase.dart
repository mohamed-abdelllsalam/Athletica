import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  const SendChatMessageUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<ChatMessage>> call({
    required String conversationId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) {
    final error = validateChatSend(content, attachment);
    if (error != null) return Future.value(ApiError(ChatFailure(error)));
    return _repository.sendMessage(
      conversationId: conversationId,
      content: content,
      attachment: attachment,
      onProgress: onProgress,
      uploadControl: uploadControl,
    );
  }
}
