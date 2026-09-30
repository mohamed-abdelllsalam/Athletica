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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(context.read<ChatDraftCubit>().stopRecording());
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
    final sent = await widget.onSend(_controller.text, draft.state.attachment);
    if (!mounted) return;
    if (sent) {
      _controller.clear();
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
    _recordingStart = cubit.startRecording();
  }

  Future<void> _stopRecordingAndSend(ChatDraftCubit cubit) async {
    final future = _recordingStart;
    _recordingStart = null;
    if (future != null) await future;
    if (!cubit.state.recording) return;
    await cubit.stopRecording();
    if (!mounted || cubit.state.attachment == null) return;
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
      return Material(
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
                      onPressed: busy ? null : () => unawaited(cubit.discard()),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              if (draft.busy) const LinearProgressIndicator(),
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
              if (draft.recording)
                Row(
                  children: [
                    const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.redAccent,
                    ),
                    Expanded(
                      child: Text(
                        'Release to send · ${draft.seconds ~/ 60}:${(draft.seconds % 60).toString().padLeft(2, '0')} / 15:00',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Discard recording',
                      onPressed: () => unawaited(cubit.discard()),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Stop recording',
                      onPressed: () => unawaited(cubit.stopRecording()),
                      icon: const Icon(Icons.stop, color: Colors.white),
                    ),
                  ],
                )
              else
                Row(
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
                        enabled: widget.enabled && !busy,
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
                        onSubmitted: (_) => unawaited(_send()),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: canAttach
                          ? (_) => _startRecording(cubit)
                          : null,
                      onTapUp: canAttach
                          ? (_) => unawaited(_stopRecordingAndSend(cubit))
                          : null,
                      onTapCancel: canAttach
                          ? () => unawaited(cubit.discard())
                          : null,
                      onLongPressStart: canAttach
                          ? (_) => _startRecording(cubit)
                          : null,
                      onLongPressEnd: canAttach
                          ? (_) => unawaited(_stopRecordingAndSend(cubit))
                          : null,
                      onLongPressCancel: canAttach
                          ? () => unawaited(cubit.discard())
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.mic,
                          semanticLabel:
                              'Press and hold to record a voice note',
                          color: canAttach ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: widget.sending
                          ? 'Cancel upload'
                          : 'Send message',
                      onPressed: widget.sending
                          ? widget.onCancel
                          : widget.enabled && !busy
                          ? _send
                          : null,
                      icon: widget.sending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: widget.progress,
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: widget.enabled && !busy
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}
