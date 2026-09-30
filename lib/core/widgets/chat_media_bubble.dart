import 'dart:async';

import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class ChatMediaBubble extends StatelessWidget {
  const ChatMediaBubble({
    super.key,
    required this.type,
    required this.isMe,
    required this.time,
    this.content,
    this.url,
    this.durationSeconds,
  });
  final MessageType type;
  final bool isMe;
  final String time;
  final String? content;
  final String? url;
  final int? durationSeconds;

  @override
  Widget build(BuildContext context) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .8,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryBlue : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type == MessageType.image)
            url == null
                ? const Text('Photo unavailable')
                : GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(backgroundColor: Colors.black),
                          body: Center(
                            child: InteractiveViewer(
                              minScale: .5,
                              maxScale: 5,
                              child: Image.network(
                                url!,
                                errorBuilder: (_, _, _) =>
                                    const Text('Could not load photo'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url!,
                        width: 240,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const SizedBox(
                                width: 240,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 240,
                          height: 100,
                          child: Center(
                            child: Text(
                              'Could not load photo',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          if (type == MessageType.voice)
            _VoicePlayer(
              key: ValueKey(url),
              url: url,
              seconds: durationSeconds,
            ),
          if (content?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                content!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _VoicePlayer extends StatefulWidget {
  const _VoicePlayer({super.key, this.url, this.seconds});
  final String? url;
  final int? seconds;
  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer>
    with WidgetsBindingObserver {
  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _player = AudioPlayer();
    _duration = Duration(seconds: widget.seconds ?? 0);
    _subscriptions.add(
      _player.onPositionChanged.listen((value) {
        if (mounted) setState(() => _position = value);
      }),
    );
    _subscriptions.add(
      _player.onDurationChanged.listen((value) {
        if (mounted) setState(() => _duration = value);
      }),
    );
    _subscriptions.add(
      _player.onPlayerStateChanged.listen((value) {
        if (mounted) setState(() => _playing = value == PlayerState.playing);
      }),
    );
  }

  Future<void> _toggle() async {
    if (widget.url == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_playing) {
        await _player.pause();
      } else {
        if (!_loaded) {
          await _player.setReleaseMode(ReleaseMode.stop);
          await _player.setSourceUrl(widget.url!);
          _loaded = true;
        }
        if (_player.state == PlayerState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.resume();
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not play. Tap to retry.');
      _loaded = false;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seek(double value) async {
    try {
      await _player.seek(Duration(milliseconds: value.round()));
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not seek. Try again.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _playing) {
      unawaited(_toggle());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: _playing ? 'Pause voice note' : 'Play voice note',
              onPressed: widget.url == null || _loading ? null : _toggle,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Icon(
                      _playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
            ),
            Expanded(
              child: Slider(
                value: _position.inMilliseconds.toDouble().clamp(
                  0,
                  _duration.inMilliseconds.toDouble(),
                ),
                max: _duration.inMilliseconds > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1,
                onChanged: _loaded && _duration.inMilliseconds > 0
                    ? (value) => unawaited(_seek(value))
                    : null,
              ),
            ),
            Text(
              '${_duration.inSeconds ~/ 60}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        if (widget.url == null) const Text('Voice note unavailable'),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
