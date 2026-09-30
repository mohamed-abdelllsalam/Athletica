import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/domain/repositories/chat_media_repository.dart';
import 'package:athletica/core/utils/api_result.dart';

class PickChatImageUseCase {
  const PickChatImageUseCase(this._repository);
  final ChatMediaRepository _repository;
  Future<ApiResult<ChatAttachment?>> call({required bool camera}) =>
      _repository.pickImage(camera: camera);
}

class StartChatRecordingUseCase {
  const StartChatRecordingUseCase(this._repository);
  final ChatMediaRepository _repository;
  Future<ApiResult<void>> call() => _repository.startRecording();
}

class StopChatRecordingUseCase {
  const StopChatRecordingUseCase(this._repository);
  final ChatMediaRepository _repository;
  Future<ApiResult<ChatAttachment?>> call() => _repository.stopRecording();
}

class DiscardChatMediaUseCase {
  const DiscardChatMediaUseCase(this._repository);
  final ChatMediaRepository _repository;
  Future<ApiResult<void>> call(ChatAttachment? attachment) =>
      _repository.discard(attachment);
}
