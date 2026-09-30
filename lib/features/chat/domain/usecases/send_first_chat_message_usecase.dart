import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/first_chat_message_result.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class SendFirstChatMessageUseCase {
  const SendFirstChatMessageUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<FirstChatMessageResult>> call({
    required String coachClientId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) {
    final error = validateChatSend(content, attachment);
    if (error != null) return Future.value(ApiError(ChatFailure(error)));
    return _repository.sendFirstMessage(
      coachClientId: coachClientId,
      content: content,
      attachment: attachment,
      onProgress: onProgress,
      uploadControl: uploadControl,
    );
  }
}
