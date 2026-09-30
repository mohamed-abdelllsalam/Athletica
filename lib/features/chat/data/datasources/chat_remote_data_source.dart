import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/chat/data/models/chat_history_page_model.dart';
import 'package:athletica/features/chat/data/models/chat_message_model.dart';
import 'package:athletica/features/chat/data/models/conversation_model.dart';
import 'package:athletica/features/chat/domain/entities/first_chat_message_result.dart';
import 'package:dio/dio.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations({required int limit});
  Future<FirstChatMessageResult> sendFirstMessage({
    required String coachClientId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  });
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  });
  Future<ChatHistoryPageModel> getHistory({
    required String conversationId,
    required int limit,
    String? before,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  CancelToken? _cancelToken(ChatUploadControl? control) {
    if (control == null) return null;
    final token = CancelToken();
    control.bind(() => token.cancel('Cancelled'));
    return token;
  }

  Future<Object> _body(String content, ChatAttachment? attachment) async {
    if (attachment == null) return {'content': content.trim()};
    return FormData.fromMap({
      'message_type': attachment.type.name,
      if (content.trim().isNotEmpty) 'content': content.trim(),
      if (attachment.durationSeconds != null)
        'duration_sec': '${attachment.durationSeconds}',
      'file': await MultipartFile.fromFile(
        attachment.path,
        filename: attachment.type == MessageType.image
            ? 'photo.jpg'
            : 'voice-note.m4a',
        contentType: DioMediaType.parse(attachment.mime),
      ),
    });
  }

  Map<String, dynamic> _data(dynamic response) =>
      (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  @override
  Future<List<ConversationModel>> getConversations({required int limit}) async {
    final response = await _dio.get(
      ApiEndpoints.messagingConversations,
      queryParameters: {'limit': limit},
    );
    final data = (response.data as Map<String, dynamic>)['data'];
    final items = data is List
        ? data
        : (data as Map<String, dynamic>)['conversations'] as List<dynamic>;
    return items
        .map((item) => ConversationModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<FirstChatMessageResult> sendFirstMessage({
    required String coachClientId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.messagingFirstMessage(coachClientId),
      data: await _body(content, attachment),
      options: Options(sendTimeout: const Duration(minutes: 5)),
      cancelToken: _cancelToken(uploadControl),
      onSendProgress: onProgress,
    );
    final data = _data(response.data);
    return FirstChatMessageResult(
      conversation: ConversationModel.fromJson(
        data['conversation'] as Map<String, dynamic>,
      ),
      message: ChatMessageModel.fromJson(
        data['message'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    ChatAttachment? attachment,
    void Function(int, int)? onProgress,
    ChatUploadControl? uploadControl,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.messagingMessages(conversationId),
      data: await _body(content, attachment),
      options: Options(sendTimeout: const Duration(minutes: 5)),
      cancelToken: _cancelToken(uploadControl),
      onSendProgress: onProgress,
    );
    return ChatMessageModel.fromJson(
      _data(response.data)['message'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ChatHistoryPageModel> getHistory({
    required String conversationId,
    required int limit,
    String? before,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.messagingMessages(conversationId),
      queryParameters: {
        'limit': limit,
        ...?(before == null ? null : {'before': before}),
      },
    );
    return ChatHistoryPageModel.fromJson(_data(response.data));
  }
}
