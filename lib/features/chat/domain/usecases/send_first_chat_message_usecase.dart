import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/first_chat_message_result.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class SendFirstChatMessageUseCase {
  const SendFirstChatMessageUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<FirstChatMessageResult>> call({
    required String coachClientId,
    required String content,
  }) => _repository.sendFirstMessage(
    coachClientId: coachClientId,
    content: content,
  );
}
