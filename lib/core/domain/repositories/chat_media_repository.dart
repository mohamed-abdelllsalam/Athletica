import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/utils/api_result.dart';

abstract interface class ChatMediaRepository {
  Future<ApiResult<ChatAttachment?>> pickImage({required bool camera});
  Future<ApiResult<void>> startRecording();
  Future<ApiResult<ChatAttachment?>> stopRecording();
  Future<ApiResult<void>> discard(ChatAttachment? attachment);
}
