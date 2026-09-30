enum MessageType { text, image, voice }

abstract final class MessagingLimits {
  static const imageMaxBytes = 10 * 1024 * 1024;
  static const voiceMaxBytes = 25 * 1024 * 1024;
  static const captionMaxChars = 2000;
  static const voiceMaxSeconds = 900;
}

class ChatAttachment {
  const ChatAttachment({
    required this.path,
    required this.type,
    required this.mime,
    required this.size,
    this.durationSeconds,
  });
  final String path;
  final MessageType type;
  final String mime;
  final int size;
  final int? durationSeconds;

  String? validate() {
    if (type == MessageType.text || size <= 0 || path.isEmpty) {
      return 'Choose a photo or record a voice note.';
    }
    if (type == MessageType.image && size > MessagingLimits.imageMaxBytes) {
      return 'Photos must be 10 MB or smaller.';
    }
    if (type == MessageType.voice && size > MessagingLimits.voiceMaxBytes) {
      return 'Voice notes must be 25 MB or smaller.';
    }
    if ((type == MessageType.image && mime != 'image/jpeg') ||
        (type == MessageType.voice && mime != 'audio/mp4' && mime != 'audio/m4a')) {
      return 'Use a JPEG photo or an AAC/M4A voice note.';
    }
    final seconds = durationSeconds;
    if (type == MessageType.voice &&
        seconds != null &&
        (seconds < 1 || seconds > MessagingLimits.voiceMaxSeconds)) {
      return 'Voice notes must be between 1 second and 15 minutes.';
    }
    return null;
  }
}

/// Transport-independent cancellation; a fresh instance is used for each send.
class ChatUploadControl {
  bool _cancelled = false;
  void Function()? _cancel;
  bool get isCancelled => _cancelled;
  void bind(void Function()? cancel) {
    _cancel = cancel;
    if (_cancelled) cancel?.call();
  }

  void cancel() {
    _cancelled = true;
    _cancel?.call();
  }
}

String? validateChatSend(String content, ChatAttachment? attachment) {
  if (content.trim().runes.length > MessagingLimits.captionMaxChars) {
    return 'Messages and captions must be 2,000 characters or fewer.';
  }
  if (attachment == null && content.trim().isEmpty) return 'Enter a message.';
  return attachment?.validate();
}
