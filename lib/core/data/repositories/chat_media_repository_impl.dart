import 'dart:io';

import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/domain/repositories/chat_media_repository.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatMediaRepositoryImpl implements ChatMediaRepository {
  AudioRecorder? _recorder;
  String? _recordingPath;
  final Stopwatch _elapsed = Stopwatch();

  Future<Directory> _directory() async {
    final base = await getTemporaryDirectory();
    final directory = await Directory('${base.path}/chat_media').create();
    // Only our generated files are eligible for stale-cache cleanup.
    await for (final entry in directory.list()) {
      if (entry is File && entry.path != _recordingPath) {
        final stat = await entry.stat();
        if (DateTime.now().difference(stat.modified).inDays >= 1) {
          try {
            await entry.delete();
          } on FileSystemException {
            /* Best effort cache cleanup. */
          }
        }
      }
    }
    return directory;
  }

  @override
  Future<ApiResult<ChatAttachment?>> pickImage({required bool camera}) async {
    String? target;
    try {
      final picked = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked == null) return const ApiSuccess(null);
      final directory = await _directory();
      target =
          '${directory.path}/photo_${DateTime.now().microsecondsSinceEpoch}.jpg';
      var compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target,
        quality: 82,
        minWidth: 1600,
        minHeight: 1600,
        format: CompressFormat.jpeg,
      );
      if (compressed == null) {
        throw const FormatException('Unable to prepare photo');
      }
      if (await compressed.length() > MessagingLimits.imageMaxBytes) {
        await File(target).delete();
        compressed = await FlutterImageCompress.compressAndGetFile(
          picked.path,
          target,
          quality: 65,
          minWidth: 1200,
          minHeight: 1200,
          format: CompressFormat.jpeg,
        );
      }
      if (compressed == null) {
        throw const FormatException('Unable to prepare photo');
      }
      final attachment = ChatAttachment(
        path: compressed.path,
        type: MessageType.image,
        mime: 'image/jpeg',
        size: await compressed.length(),
      );
      final error = attachment.validate();
      if (error != null) {
        await File(target).delete();
        return ApiError(ChatFailure(error));
      }
      return ApiSuccess(attachment);
    } catch (_) {
      if (target != null) {
        try {
          await File(target).delete();
        } on FileSystemException {
          /* May not exist. */
        }
      }
      return const ApiError(
        ChatFailure(
          'Could not prepare the photo. Check camera or photo permissions and try again.',
        ),
      );
    }
  }

  @override
  Future<ApiResult<void>> startRecording() async {
    try {
      if (_recorder != null) {
        return const ApiError(
          ChatFailure('A recording is already in progress.'),
        );
      }
      final recorder = AudioRecorder();
      _recorder = recorder;
      if (!await recorder.hasPermission()) {
        await _releaseRecorder();
        return const ApiError(
          ChatFailure(
            'Allow microphone access in Settings to record a voice note.',
          ),
        );
      }
      final directory = await _directory();
      _recordingPath =
          '${directory.path}/voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 96000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordingPath!,
      );
      _elapsed
        ..reset()
        ..start();
      return const ApiSuccess(null);
    } catch (_) {
      await discard(null);
      return const ApiError(
        ChatFailure('Could not start recording. Try again.'),
      );
    }
  }

  @override
  Future<ApiResult<ChatAttachment?>> stopRecording() async {
    final path = _recordingPath;
    try {
      final recorder = _recorder;
      if (recorder == null) return const ApiSuccess(null);
      _elapsed.stop();
      final result = await recorder.stop();
      await _releaseRecorder();
      if (result == null) throw const FormatException('No recording');
      final attachment = ChatAttachment(
        path: result,
        type: MessageType.voice,
        mime: 'audio/mp4',
        size: await File(result).length(),
        durationSeconds: (_elapsed.elapsedMilliseconds / 1000).ceil(),
      );
      final error = attachment.validate();
      if (error != null) {
        await discard(attachment);
        return ApiError(ChatFailure(error));
      }
      return ApiSuccess(attachment);
    } catch (_) {
      await _releaseRecorder();
      if (path != null) {
        try {
          await File(path).delete();
        } on FileSystemException {
          /* May not exist. */
        }
      }
      return const ApiError(
        ChatFailure('Could not save this recording. Please record it again.'),
      );
    }
  }

  Future<void> _releaseRecorder() async {
    final recorder = _recorder;
    _recorder = null;
    _recordingPath = null;
    _elapsed.stop();
    await recorder?.dispose();
  }

  @override
  Future<ApiResult<void>> discard(ChatAttachment? attachment) async {
    try {
      final path = attachment?.path ?? _recordingPath;
      if (attachment == null) {
        await _recorder?.cancel();
        await _releaseRecorder();
      }
      if (path != null) {
        final base = await getTemporaryDirectory();
        final directory = Directory('${base.path}/chat_media').absolute.path;
        final file = File(path).absolute;
        if (file.path.startsWith('$directory${Platform.pathSeparator}') &&
            await file.exists()) {
          await file.delete();
        }
      }
      return const ApiSuccess(null);
    } catch (_) {
      return const ApiError(
        ChatFailure('Could not clear the temporary media file.'),
      );
    }
  }
}
