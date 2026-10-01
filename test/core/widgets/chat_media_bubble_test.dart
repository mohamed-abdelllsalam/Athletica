import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/widgets/chat_media_bubble.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _AudioChannels {
  final calls = <MethodCall>[];
  final positions = <String, int>{};
  final playerIds = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  static const codec = StandardMethodCodec();

  void install() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        final args = call.arguments as Map;
        final id = args['playerId'] as String;
        switch (call.method) {
          case 'create':
            playerIds.add(id);
            positions[id] = 0;
            messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$id'),
              (_) async => null,
            );
          case 'setSourceUrl':
            await event(id, 'audio.onPrepared', true);
          case 'seek':
            positions[id] = args['position'] as int;
            await event(id, 'audio.onSeekComplete', null);
          case 'getCurrentPosition':
            return positions[id];
        }
        return null;
      },
    );
  }

  Future<void> event(String id, String event, Object? value) async {
    TestWidgetsFlutterBinding.instance.channelBuffers.push(
      'xyz.luan/audioplayers/events/$id',
      codec.encodeSuccessEnvelope({'event': event, 'value': value}),
      (_) {},
    );
  }

  List<MethodCall> named(String name) =>
      calls.where((call) => call.method == name).toList();
}

Future<void> flush(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _AudioChannels audio;
  setUpAll(() async {
    _AudioChannels().install();
    await AudioPlayer.global.ensureInitialized();
  });
  setUp(() {
    audio = _AudioChannels()..install();
  });

  Future<void> mount(WidgetTester tester, {bool twoNotes = false}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const ChatMediaBubble(
                  type: MessageType.voice,
                  isMe: true,
                  time: '10:00',
                  url: 'https://example.com/first.m4a',
                  durationSeconds: 60,
                ),
                if (twoNotes)
                  const ChatMediaBubble(
                    type: MessageType.voice,
                    isMe: false,
                    time: '10:01',
                    url: 'https://example.com/second.m4a',
                    durationSeconds: 60,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await flush(tester);
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await flush(tester);
  }

  testWidgets('drag previews elapsed time and seeks only on release', (
    tester,
  ) async {
    await mount(tester);
    final slider = find.byType(Slider);
    final center = tester.getCenter(slider);
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(audio.named('seek'), isEmpty);
    final preview = tester.widget<Slider>(slider).value;
    expect(preview, greaterThan(0));
    expect(
      find.text('0:${(preview ~/ 1000).toString().padLeft(2, '0')}'),
      findsOneWidget,
    );
    await gesture.up();
    await flush(tester);
    expect(audio.named('seek'), hasLength(1));
    expect(
      (audio.named('seek').single.arguments as Map)['position'],
      preview.round(),
    );
    await cleanup(tester);
  });

  testWidgets('playing shows elapsed position instead of total duration', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('1:00'), findsOneWidget);
    audio.positions[audio.playerIds.single] = 12000;
    await tester.tap(find.byTooltip('Play voice note'));
    await flush(tester);
    expect(find.text('0:12'), findsOneWidget);
    expect(find.byTooltip('Pause voice note'), findsOneWidget);
    await cleanup(tester);
  });

  testWidgets('playback speed cycles through 1.5, 2 and 1', (tester) async {
    await mount(tester);
    await tester.tap(find.byTooltip('Play voice note'));
    await flush(tester);
    for (final (current, next) in [
      ('1×', '1.5×'),
      ('1.5×', '2×'),
      ('2×', '1×'),
    ]) {
      await tester.tap(find.text(current));
      await flush(tester);
      expect(find.text(next), findsOneWidget);
    }
    expect(
      audio
          .named('setPlaybackRate')
          .map((call) => (call.arguments as Map)['playbackRate']),
      [1.0, 1.5, 2.0, 1.0],
    );
    await cleanup(tester);
  });

  testWidgets('starting another voice note pauses the previous note first', (
    tester,
  ) async {
    await mount(tester, twoNotes: true);
    await tester.tap(find.byTooltip('Play voice note').first);
    await flush(tester);
    final firstId = (audio.named('resume').single.arguments as Map)['playerId'];
    audio.calls.clear();
    await tester.tap(find.byTooltip('Play voice note'));
    await flush(tester);
    final playbackCalls = audio.calls
        .where((call) => call.method == 'pause' || call.method == 'resume')
        .toList();
    expect(playbackCalls.map((call) => call.method), ['pause', 'resume']);
    expect((playbackCalls.first.arguments as Map)['playerId'], firstId);
    expect((playbackCalls.last.arguments as Map)['playerId'], isNot(firstId));
    expect(find.byTooltip('Pause voice note'), findsOneWidget);
    await cleanup(tester);
  });

  testWidgets(
    'completed note ignores trailing position and replays from zero',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byTooltip('Play voice note'));
      await flush(tester);
      final id = audio.playerIds.single;
      audio.positions[id] = 60000;
      await audio.event(id, 'audio.onComplete', null);
      await flush(tester);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 0);
      await tester.tap(find.byTooltip('Play voice note'));
      await flush(tester);
      expect((audio.named('seek').single.arguments as Map)['position'], 0);
      expect(find.byTooltip('Pause voice note'), findsOneWidget);
      await cleanup(tester);
    },
  );
}
