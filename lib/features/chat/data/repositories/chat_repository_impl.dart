import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:athletica/features/chat/domain/entities/chat_history_page.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/entities/first_chat_message_result.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';
import 'package:dio/dio.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remoteDataSource);
  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<Conversation>>> getConversations({
    int limit = 50,
  }) async => _guard(
    () => _remoteDataSource.getConversations(limit: limit),
    (items) => items.cast<Conversation>(),
  );

  @override
  Future<ApiResult<ChatHistoryPage>> getHistory({
    required String conversationId,
    String? before,
    int limit = 50,
  }) async => _guard(
    () => _remoteDataSource.getHistory(
      conversationId: conversationId,
      before: before,
      limit: limit,
    ),
    (page) => page,
  );

  @override
  Future<ApiResult<ChatMessage>> sendMessage({
    required String conversationId,
    required String content,
  }) async => _guard(
    () => _remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
    ),
    (message) => message,
  );

  @override
  Future<ApiResult<FirstChatMessageResult>> sendFirstMessage({
    required String coachClientId,
    required String content,
  }) async => _guard(
    () => _remoteDataSource.sendFirstMessage(
      coachClientId: coachClientId,
      content: content,
    ),
    (result) => result,
  );

  Future<ApiResult<T>> _guard<R, T>(
    Future<R> Function() action,
    T Function(R value) map,
  ) async {
    try {
      return ApiSuccess(map(await action()));
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401) {
        return ApiError(
          const UnauthorizedFailure('Session expired. Sign in again.'),
        );
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return ApiError(
          const NetworkFailure('Check your connection and try again.'),
        );
      }
      final message = switch (status) {
        400 => 'The chat request is invalid.',
        403 => 'Chat is unavailable for this account.',
        404 => 'Conversation not found.',
        _ => 'Chat service is temporarily unavailable.',
      };
      return ApiError(ChatFailure(message, statusCode: status));
    } on FormatException {
      return ApiError(const ChatFailure('The chat response was invalid.'));
    } catch (_) {
      return ApiError(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
