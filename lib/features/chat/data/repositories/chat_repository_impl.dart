import 'package:athletica/core/domain/entities/chat_attachment.dart';
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
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) async => _guard(
    () => _remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
      attachment: attachment,
      onProgress: onProgress,
      uploadControl: uploadControl,
    ),
    (message) => message,
  );

  @override
  Future<ApiResult<FirstChatMessageResult>> sendFirstMessage({
    required String coachClientId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) async => _guard(
    () => _remoteDataSource.sendFirstMessage(
      coachClientId: coachClientId,
      content: content,
      attachment: attachment,
      onProgress: onProgress,
      uploadControl: uploadControl,
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
      if (error.type == DioExceptionType.cancel) {
        return const ApiError(ChatFailure('Upload cancelled.'));
      }
      final body = error.response?.data;
      final keys = <String>{};
      if (body is Map) {
        if (body['code'] is String) {
          keys.add(body['code'] as String);
        }
        if (body['details'] is List) {
          keys.addAll((body['details'] as List).whereType<String>());
        }
      }
      final mediaError = switch (keys) {
        _ when keys.contains('attachment_required') =>
          'Could not attach that file. Try again.',
        _
            when keys.contains('message_invalid_file_type') ||
                keys.contains('invalid_message_type') =>
          'Only photos and voice notes can be sent.',
        _ when keys.contains('message_content_too_long') =>
          'Captions must be 2,000 characters or fewer.',
        _
            when keys.contains('voice_too_long') ||
                keys.contains('invalid_duration') =>
          'Voice notes must be between 1 second and 15 minutes.',
        _ when keys.contains('image_too_large') =>
          'Photos must be 10 MB or smaller.',
        _ when keys.contains('voice_too_large') =>
          'Voice notes must be 25 MB or smaller.',
        _ => null,
      };
      final status = error.response?.statusCode;
      if (mediaError != null) {
        return ApiError(ChatFailure(mediaError, statusCode: status));
      }
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
        413 => 'File too large. Choose a smaller photo or a shorter recording.',
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
