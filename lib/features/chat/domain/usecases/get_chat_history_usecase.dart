import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/chat_history_page.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  const GetChatHistoryUseCase(this._repository);
  final ChatRepository _repository;

  Future<ApiResult<ChatHistoryPage>> call({
    required String conversationId,
    String? before,
    int limit = 50,
  }) => _repository.getHistory(
    conversationId: conversationId,
    before: before,
    limit: limit,
  );
}
