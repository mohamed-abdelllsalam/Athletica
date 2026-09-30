import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'dart:async';
import 'dart:collection';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/domain/realtime/chat_realtime_gateway.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_conversations_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/send_first_chat_message_usecase.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required GetChatConversationsUseCase getConversations,
    required GetChatHistoryUseCase getHistory,
    required SendChatMessageUseCase sendMessage,
    required SendFirstChatMessageUseCase sendFirstMessage,
    required ChatRealtimeGateway realtimeGateway,
    this.conversationId,
    this.coachClientId,
    this.canStartConversation = false,
  }) : _getConversations = getConversations,
       _getHistory = getHistory,
       _sendMessage = sendMessage,
       _sendFirstMessage = sendFirstMessage,
       _realtimeGateway = realtimeGateway,
       super(const ChatInitial());

  final GetChatConversationsUseCase _getConversations;
  final GetChatHistoryUseCase _getHistory;
  final SendChatMessageUseCase _sendMessage;
  final SendFirstChatMessageUseCase _sendFirstMessage;
  final ChatRealtimeGateway _realtimeGateway;
  final String? coachClientId;
  final bool canStartConversation;

  String? conversationId;
  final List<ChatMessage> _messages = [];
  final LinkedHashSet<String> _seenMessageIds = LinkedHashSet<String>();
  final LinkedHashSet<String> _seenEventIds = LinkedHashSet<String>();
  String? _cursor;
  bool _hasMore = false;
  bool _loadingOlder = false;
  bool _loadedOlderPages = false;
  bool _sending = false;
  double? _uploadProgress;
  ChatUploadControl? _uploadControl;
  bool _realtimeAvailable = false;
  bool _opened = false;
  String? _error;
  Timer? _pollTimer;

  Future<void> open() async {
    if ((_opened && state is! ChatFailureState) || isClosed) return;
    _opened = true;
    final requestedConversationId = conversationId;
    if (requestedConversationId == null) {
      emit(const ChatLoading());
      final result = await _getConversations();
      if (isClosed) return;
      switch (result) {
        case ApiSuccess(:final data):
          final assignmentId = coachClientId;
          final match = assignmentId == null
              ? (data.isEmpty ? null : data.first)
              : _firstWhereOrNull(
                  data,
                  (conversation) => conversation.coachClientId == assignmentId,
                );
          conversationId = match?.id;
          if (conversationId == null) {
            _emitReady();
            return;
          }
        case ApiError(:final failure):
          emit(ChatFailureState(failure.message));
          return;
      }
    }
    await loadHistory(initial: true);
    if (conversationId != null) await _connectRealtime();
  }

  Future<void> loadHistory({bool initial = false}) async {
    final id = conversationId;
    if (id == null) {
      _emitReady();
      return;
    }
    if (initial && _messages.isEmpty) emit(const ChatLoading());
    final result = await _getHistory(conversationId: id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        _merge(data.messages);
        if (!_loadedOlderPages) {
          _cursor = data.nextCursor;
          _hasMore = data.hasMore;
        }
        _error = null;
      case ApiError(:final failure):
        _error = failure.message;
        if (_messages.isEmpty) {
          emit(ChatFailureState(failure.message));
          return;
        }
    }
    _emitReady();
  }

  Future<void> loadOlder() async {
    final id = conversationId;
    final cursor = _cursor;
    if (id == null || cursor == null || !_hasMore || _loadingOlder) return;
    _loadingOlder = true;
    _emitReady();
    final result = await _getHistory(conversationId: id, before: cursor);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        _merge(data.messages);
        _cursor = data.nextCursor;
        _hasMore = data.hasMore;
        _loadedOlderPages = true;
        _error = null;
      case ApiError(:final failure):
        _error = failure.message;
    }
    _loadingOlder = false;
    _emitReady();
  }

  Future<bool> send(String rawContent, {ChatAttachment? attachment}) async {
    final content = rawContent.trim();
    if (_sending || isClosed) return false;
    final validation = validateChatSend(content, attachment);
    if (validation != null) {
      _error = validation;
      _emitReady();
      return false;
    }
    if (conversationId == null && !canStartConversation) return false;
    _uploadControl = ChatUploadControl();
    _uploadProgress = attachment == null ? null : 0;
    _sending = true;
    _error = null;
    _emitReady();
    var sentSuccessfully = false;
    final currentId = conversationId;
    if (currentId == null) {
      final assignmentId = coachClientId;
      if (assignmentId == null || assignmentId.isEmpty) {
        _error = 'Chat assignment is unavailable.';
      } else {
        final result = await _sendFirstMessage(
          coachClientId: assignmentId,
          content: content,
          attachment: attachment,
          uploadControl: _uploadControl,
          onProgress: (sent, total) {
            _uploadProgress = total <= 0 ? null : sent / total;
            _emitReady();
          },
        );
        if (isClosed) return false;
        switch (result) {
          case ApiSuccess(:final data):
            sentSuccessfully = true;
            conversationId = data.conversation.id;
            _insertNewest(data.message);
            _hasMore = false;
            await _connectRealtime();
          case ApiError(:final failure):
            _error = failure.message;
        }
      }
    } else {
      final result = await _sendMessage(
        conversationId: currentId,
        content: content,
        attachment: attachment,
        uploadControl: _uploadControl,
        onProgress: (sent, total) {
          _uploadProgress = total <= 0 ? null : sent / total;
          _emitReady();
        },
      );
      if (isClosed) return false;
      switch (result) {
        case ApiSuccess(:final data):
            sentSuccessfully = true;
          _insertNewest(data);
        case ApiError(:final failure):
          _error = failure.message;
      }
    }
    final cancelled = _uploadControl?.isCancelled ?? false;
    _uploadControl?.bind(null);
    _uploadControl = null;
    _sending = false;
    _uploadProgress = null;
    if (cancelled) _error = null;
    _emitReady();
    return sentSuccessfully;
  }

  void cancelUpload() => _uploadControl?.cancel();

  void receive(ChatRealtimeEvent event) {
    if (!_remember(_seenEventIds, event.eventId)) return;
    _insertNewest(event.message);
    _emitReady();
  }

  Future<void> resume() async {
    if (conversationId == null) return;
    await loadHistory();
    await _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    final id = conversationId;
    if (id == null || isClosed) return;
    try {
      await _realtimeGateway.connect(
        id,
        onEvent: receive,
        onAvailabilityChanged: (available) {
          final becameAvailable = available && !_realtimeAvailable;
          _realtimeAvailable = available;
          if (available) {
            _pollTimer?.cancel();
            _pollTimer = null;
          } else {
            _pollTimer ??= Timer.periodic(
              const Duration(seconds: 15),
              (_) => unawaited(loadHistory()),
            );
          }
          _emitReady();
          if (becameAvailable && conversationId == id) {
            unawaited(loadHistory());
          }
        },
      );
    } catch (_) {
      _realtimeAvailable = false;
      _pollTimer ??= Timer.periodic(
        const Duration(seconds: 15),
        (_) => unawaited(loadHistory()),
      );
      _emitReady();
    }
  }

  void _merge(List<ChatMessage> messages) {
    for (final message in messages) {
      if (message.conversationId != conversationId ||
          !_remember(_seenMessageIds, message.id)) {
        continue;
      }
      _messages.add(message);
    }
  }

  void _insertNewest(ChatMessage message) {
    if (message.conversationId != conversationId ||
        !_remember(_seenMessageIds, message.id)) {
      return;
    }
    _messages.insert(0, message);
  }

  bool _remember(LinkedHashSet<String> values, String value) {
    if (!values.add(value)) return false;
    if (identical(values, _seenEventIds) && values.length > 500) {
      values.remove(values.first);
    }
    return true;
  }

  T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }

  void _emitReady() {
    if (isClosed) return;
    emit(
      ChatReady(
        messages: List.unmodifiable(_messages),
        conversationId: conversationId,
        canSend: conversationId != null || canStartConversation,
        hasMore: _hasMore,
        isLoadingOlder: _loadingOlder,
        isSending: _sending,
        uploadProgress: _uploadProgress,
        realtimeAvailable: _realtimeAvailable,
        errorMessage: _error,
      ),
    );
  }

  @override
  Future<void> close() async {
    _uploadControl?.cancel();
    _pollTimer?.cancel();
    _pollTimer = null;
    await _realtimeGateway.dispose();
    _messages.clear();
    _seenEventIds.clear();
    _seenMessageIds.clear();
    await super.close();
  }
}
