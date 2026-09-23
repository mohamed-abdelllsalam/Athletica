import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class GetChatConversationsUseCase {
  const GetChatConversationsUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<List<Conversation>>> call({int limit = 50}) =>
      _repository.getConversations(limit: limit);
}
