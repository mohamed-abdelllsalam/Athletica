import 'dart:async';
import 'dart:io';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/presentation/cubits/chat_draft_cubit.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMediaComposer extends StatelessWidget {
  const ChatMediaComposer({
    super.key,
    required this.onSend,
    required this.enabled,
    required this.sending,
    required this.onCancel,
    this.progress,
  });
  final Future<bool> Function(String, ChatAttachment?) onSend;
  final bool enabled;
  final bool sending;
  final double? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ChatDraftCubit>(),
    child: _ComposerBody(
      onSend: onSend,
      enabled: enabled,
      sending: sending,
      progress: progress,
      onCancel: onCancel,
    ),
  );
}

class _ComposerBody extends StatefulWidget {
  const _ComposerBody({
    required this.onSend,
    required this.enabled,
    required this.sending,
    required this.onCancel,
    this.progress,
  });
  final Future<bool> Function(String, ChatAttachment?) onSend;
  final bool enabled;
  final bool sending;
  final double? progress;
  final VoidCallback onCancel;
  @override
  State<_ComposerBody> createState() => _ComposerBodyState();
}

class _ComposerBodyState extends State<_ComposerBody>
    with WidgetsBindingObserver {
  late final TextEditingController _controller;
  bool _awaitingSend = false;
  bool _failed = false;
  Future<void>? _recordingStart;
  bool _holding = false;
  bool _locked = false;
  bool _cancelled = false;
  Offset? _recordingOrigin;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<ChatDraftCubit>();
    if (state == AppLifecycleState.paused ||
        (state == AppLifecycleState.inactive && cubit.state.recording)) {
      unawaited(_preserveRecording(cubit));
    }
  }

  Future<void> _preserveRecording(ChatDraftCubit cubit) async {
    _cancelled = true;
    final start = _recordingStart;
    if (start != null) await start;
    if (!mounted || cubit.isClosed) return;
    await cubit.stopRecording();
    if (mounted) {
      setState(() {
        _holding = false;
        _locked = false;
        _recordingStart = null;
      });
    }
  }

  Future<void> _send() async {
    final draft = context.read<ChatDraftCubit>();
    if (_awaitingSend ||
        widget.sending ||
        !widget.enabled ||
        draft.state.busy ||
        draft.state.recording) {
      return;
    }
    setState(() {
      _awaitingSend = true;
      _failed = false;
    });
    final text = _controller.text;
    final sent = await widget.onSend(text, draft.state.attachment);
    if (!mounted) return;
    if (sent) {
      if (_controller.text == text) _controller.clear();
      if (draft.state.attachment != null) {
        await draft.discard();
      }
    }
    if (mounted) {
      setState(() {
        _awaitingSend = false;
        _failed = !sent;
      });
    }
  }

  void _startRecording(ChatDraftCubit cubit) {
    if (_recordingStart != null || cubit.state.recording) return;
    setState(() {
      _holding = true;
      _locked = false;
      _cancelled = false;
    });
    _recordingStart = cubit.startRecording().then((_) {
      if (mounted && !cubit.isClosed && !cubit.state.recording) {
        setState(() {
          _holding = false;
          _locked = false;
        });
      }
    });
  }

  void _moveRecording(
    LongPressMoveUpdateDetails details,
    ChatDraftCubit cubit,
  ) {
    if (!_holding || _locked || _cancelled) return;
    final offset = details.globalPosition - _recordingOrigin!;
    if (offset.dx < -80) {
      setState(() => _cancelled = true);
      unawaited(_cancelRecording(cubit));
    } else if (offset.dy < -70) {
      setState(() => _locked = true);
    }
  }

  Future<void> _cancelRecording(ChatDraftCubit cubit) async {
    _cancelled = true;
    final start = _recordingStart;
    if (start != null) await start;
    if (!mounted || cubit.isClosed) return;
    await cubit.discard();
    if (mounted) {
      setState(() {
        _holding = false;
        _locked = false;
        _recordingStart = null;
      });
    }
  }

  Future<void> _stopRecordingAndSend(ChatDraftCubit cubit) async {
    final future = _recordingStart;
    if (future != null) await future;
    _recordingStart = null;
    if (!mounted || cubit.isClosed || _cancelled) return;
    setState(() => _holding = false);
    if (_locked) return;
    if (!cubit.state.recording) return;
    await cubit.stopRecording();
    if (!mounted || _cancelled || cubit.state.attachment == null) return;
    await _send();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ChatDraftCubit, ChatDraftState>(
    builder: (context, draft) {
      final cubit = context.read<ChatDraftCubit>();
      final busy = widget.sending || _awaitingSend || draft.busy;
      final canAttach =
          widget.enabled &&
          !busy &&
          !draft.recording &&
          draft.attachment == null;
      final attachment = draft.attachment;
      return TextFieldTapRegion(
        child: Material(
          color: AppColors.cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (draft.error != null)
                  Text(
                    draft.error!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                if (attachment != null)
                  Row(
                    children: [
                      if (attachment.type == MessageType.image)
                        Image.file(
                          File(attachment.path),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image),
                        )
                      else
                        const Icon(Icons.mic, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attachment.type == MessageType.image
                              ? 'Photo'
                              : 'Voice note · ${attachment.durationSeconds ?? 0}s',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Discard attachment',
                        onPressed: busy
                            ? null
                            : () => unawaited(cubit.discard()),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                if (draft.recording || _holding)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      key: const ValueKey('chat-recording-details'),
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${draft.seconds ~/ 60}:${(draft.seconds % 60).toString().padLeft(2, '0')}  ${_locked ? 'Locked' : '‹ Slide to cancel · ↑ Lock'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (draft.recording && _locked)
                          IconButton(
                            tooltip: 'Discard recording',
                            onPressed: () => unawaited(_cancelRecording(cubit)),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_failed && !busy)
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Draft kept',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextButton(onPressed: _send, child: const Text('Retry')),
                    ],
                  ),
                Row(
                  key: const ValueKey('chat-composer-controls'),
                  children: [
                    PopupMenuButton<bool>(
                      enabled: canAttach,
                      tooltip: 'Attach photo',
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: canAttach ? Colors.white : Colors.grey,
                      ),
                      onSelected: (camera) =>
                          unawaited(cubit.pickImage(camera: camera)),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: false, child: Text('Gallery')),
                        PopupMenuItem(value: true, child: Text('Camera')),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled:
                            widget.enabled && !draft.recording && !_holding,
                        maxLength: MessagingLimits.captionMaxChars,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: attachment == null
                              ? 'Message'
                              : 'Add a caption',
                          hintStyle: const TextStyle(color: Colors.white54),
                          counterText: '',
                        ),
                        onEditingComplete: () {},
                        onSubmitted: (_) => unawaited(_send()),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPressStart: canAttach || _holding
                          ? (details) {
                              _recordingOrigin = details.globalPosition;
                              _startRecording(cubit);
                            }
                          : null,
                      onLongPressMoveUpdate: canAttach || _holding
                          ? (details) => _moveRecording(details, cubit)
                          : null,
                      onLongPressEnd: canAttach || _holding
                          ? (_) => unawaited(_stopRecordingAndSend(cubit))
                          : null,
                      onLongPressCancel: canAttach || _holding
                          ? () => unawaited(_cancelRecording(cubit))
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _locked ? Icons.lock : Icons.mic,
                          semanticLabel:
                              'Press and hold to record a voice note',
                          color: canAttach || _holding || draft.recording
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: widget.sending
                          ? 'Cancel upload'
                          : 'Send message',
                      onPressed: widget.sending
                          ? widget.onCancel
                          : draft.recording && _locked
                          ? () async {
                              setState(() => _locked = false);
                              await cubit.stopRecording();
                              if (mounted &&
                                  !_cancelled &&
                                  cubit.state.attachment != null) {
                                await _send();
                              }
                            }
                          : widget.enabled && !busy && !draft.recording
                          ? _send
                          : null,
                      icon: busy
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: widget.sending
                                        ? widget.progress?.clamp(0.0, 1.0)
                                        : null,
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                if (widget.sending)
                                  const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                              ],
                            )
                          : Icon(
                              Icons.send,
                              color:
                                  widget.enabled &&
                                      (!busy || _locked) &&
                                      (!draft.recording || _locked)
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
