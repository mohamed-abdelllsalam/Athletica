import 'dart:async';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/domain/usecases/chat_media_usecases.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDraftState {
  const ChatDraftState({
    this.attachment,
    this.busy = false,
    this.recording = false,
    this.seconds = 0,
    this.error,
  });
  final ChatAttachment? attachment;
  final bool busy;
  final bool recording;
  final int seconds;
  final String? error;
}

class ChatDraftCubit extends Cubit<ChatDraftState> {
  ChatDraftCubit(this._pick, this._start, this._stop, this._discard)
    : super(const ChatDraftState());
  final PickChatImageUseCase _pick;
  final StartChatRecordingUseCase _start;
  final StopChatRecordingUseCase _stop;
  final DiscardChatMediaUseCase _discard;
  Timer? _timer;
  final Stopwatch _elapsed = Stopwatch();

  Future<void> pickImage({required bool camera}) async {
    if (state.busy || state.recording || state.attachment != null) return;
    emit(const ChatDraftState(busy: true));
    final result = await _pick(camera: camera);
    if (isClosed) {
      if (result case ApiSuccess(:final data)) {
        if (data != null) await _discard(data);
      }
      return;
    }
    switch (result) {
      case ApiSuccess(:final data):
        emit(ChatDraftState(attachment: data));
      case ApiError(:final failure):
        emit(ChatDraftState(error: failure.message));
    }
  }

  Future<void> startRecording() async {
    if (state.busy || state.recording || state.attachment != null) return;
    emit(const ChatDraftState(busy: true));
    final result = await _start();
    if (isClosed) {
      await _discard(null);
      return;
    }
    switch (result) {
      case ApiError(:final failure):
        emit(ChatDraftState(error: failure.message));
      case ApiSuccess():
        _elapsed
          ..reset()
          ..start();
        emit(const ChatDraftState(recording: true));
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (isClosed) return;
          if (_elapsed.elapsed.inSeconds >=
              MessagingLimits.voiceMaxSeconds - 1) {
            unawaited(stopRecording());
          } else {
            emit(
              ChatDraftState(
                recording: true,
                seconds: _elapsed.elapsed.inSeconds,
              ),
            );
          }
        });
    }
  }

  Future<void> stopRecording() async {
    if (!state.recording || state.busy) return;
    _timer?.cancel();
    _elapsed.stop();
    emit(ChatDraftState(busy: true, seconds: state.seconds));
    final result = await _stop();
    if (isClosed) {
      if (result case ApiSuccess(:final data)) {
        if (data != null) await _discard(data);
      }
      return;
    }
    switch (result) {
      case ApiSuccess(:final data):
        emit(ChatDraftState(attachment: data));
      case ApiError(:final failure):
        emit(ChatDraftState(error: failure.message));
    }
  }

  Future<void> discard() async {
    if (state.busy) return;
    _timer?.cancel();
    _elapsed.stop();
    final attachment = state.attachment;
    emit(const ChatDraftState(busy: true));
    final result = await _discard(attachment);
    if (isClosed) return;
    emit(
      ChatDraftState(
        error: result is ApiError<void> ? result.failure.message : null,
      ),
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    _elapsed.stop();
    final attachment = state.attachment;
    final recording = state.recording;
    await super.close();
    if (attachment != null || recording) await _discard(attachment);
  }
}
