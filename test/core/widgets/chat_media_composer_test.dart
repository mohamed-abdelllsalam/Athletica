import 'dart:async';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/domain/repositories/chat_media_repository.dart';
import 'package:athletica/core/domain/usecases/chat_media_usecases.dart';
import 'package:athletica/core/presentation/cubits/chat_draft_cubit.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/chat_media_composer.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMediaRepository implements ChatMediaRepository {
  static const voice = ChatAttachment(
    path: 'voice.m4a',
    type: MessageType.voice,
    mime: 'audio/mp4',
    size: 100,
    durationSeconds: 2,
  );

  Completer<ApiResult<void>>? pendingStart;
  Completer<ApiResult<ChatAttachment?>>? pendingPick;
  Completer<ApiResult<void>>? pendingDiscard;
  int starts = 0;
  int stops = 0;
  int discards = 0;

  @override
  Future<ApiResult<ChatAttachment?>> pickImage({required bool camera}) async =>
      pendingPick == null ? const ApiSuccess(null) : await pendingPick!.future;

  @override
  Future<ApiResult<void>> startRecording() async {
    starts++;
    return pendingStart == null
        ? const ApiSuccess<void>(null)
        : await pendingStart!.future;
  }

  @override
  Future<ApiResult<ChatAttachment?>> stopRecording() async {
    stops++;
    return const ApiSuccess(voice);
  }

  @override
  Future<ApiResult<void>> discard(ChatAttachment? attachment) async {
    discards++;
    return pendingDiscard == null
        ? const ApiSuccess<void>(null)
        : await pendingDiscard!.future;
  }
}

void main() {
  late _FakeMediaRepository repository;
  late List<ChatAttachment?> sent;

  setUp(() async {
    await sl.reset();
    repository = _FakeMediaRepository();
    sent = [];
    sl.registerFactory<ChatDraftCubit>(
      () => ChatDraftCubit(
        PickChatImageUseCase(repository),
        StartChatRecordingUseCase(repository),
        StopChatRecordingUseCase(repository),
        DiscardChatMediaUseCase(repository),
      ),
    );
  });

  tearDown(() async => sl.reset());

  Future<void> mount(
    WidgetTester tester, {
    Future<bool> Function(String, ChatAttachment?)? onSend,
    ValueNotifier<bool>? sending,
  }) async {
    final sendingState = sending ?? ValueNotifier(false);
    if (sending == null) addTearDown(sendingState.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: UnfocusOnTap(
            child: Scaffold(
              bottomNavigationBar: ValueListenableBuilder<bool>(
                valueListenable: sendingState,
                builder: (_, isSending, _) => ChatMediaComposer(
                  enabled: true,
                  sending: isSending,
                  onCancel: () {},
                  onSend:
                      onSend ??
                      (_, attachment) async {
                        sent.add(attachment);
                        return true;
                      },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> holdMicrophone(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.mic)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    return gesture;
  }

  testWidgets('releasing a held recording sends after recording UI rebuilds', (
    tester,
  ) async {
    await mount(tester);
    final gesture = await holdMicrophone(tester);
    expect(repository.starts, 1);
    expect(find.textContaining('Slide to cancel'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(repository.stops, 1);
    expect(sent, [_FakeMediaRepository.voice]);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('sliding left discards a held recording without sending', (
    tester,
  ) async {
    await mount(tester);
    final gesture = await holdMicrophone(tester);

    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(repository.discards, 1);
    expect(repository.stops, 0);
    expect(sent, isEmpty);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('sliding up locks recording and release keeps it recording', (
    tester,
  ) async {
    await mount(tester);
    final gesture = await holdMicrophone(tester);

    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.textContaining('Locked'), findsOneWidget);
    expect(repository.stops, 0);
    expect(sent, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('send button stops and sends a locked recording', (tester) async {
    await mount(tester);
    final gesture = await holdMicrophone(tester);
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(repository.stops, 1);
    expect(sent, [_FakeMediaRepository.voice]);
  });

  testWidgets('release while recording start is pending sends once it starts', (
    tester,
  ) async {
    repository.pendingStart = Completer<ApiResult<void>>();
    await mount(tester);
    final gesture = await holdMicrophone(tester);

    await gesture.up();
    await tester.pump();
    expect(repository.stops, 0);
    expect(sent, isEmpty);

    repository.pendingStart!.complete(const ApiSuccess<void>(null));
    await tester.pumpAndSettle();

    expect(repository.stops, 1);
    expect(sent, [_FakeMediaRepository.voice]);
  });

  testWidgets('upload progress exposes cancel control that cancels upload', (
    tester,
  ) async {
    var cancellations = 0;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: ChatMediaComposer(
              enabled: true,
              sending: true,
              progress: .4,
              onCancel: () => cancellations++,
              onSend: (_, _) async => true,
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      .4,
    );
    await tester.tap(find.byTooltip('Cancel upload'));
    expect(cancellations, 1);
  });

  testWidgets('recording details stay above the mounted message input', (
    tester,
  ) async {
    await mount(tester);
    final input = tester.element(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Caption kept');
    final gesture = await holdMicrophone(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.element(find.byType(TextField)), same(input));
    expect(find.text('Caption kept'), findsOneWidget);
    final details = tester.getRect(find.textContaining('Slide to cancel'));
    final field = tester.getRect(find.byType(TextField));
    expect(details.bottom, lessThanOrEqualTo(field.top));

    await gesture.moveBy(const Offset(-100, 0));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('draft processing shows progress only inside the send button', (
    tester,
  ) async {
    repository.pendingPick = Completer<ApiResult<ChatAttachment?>>();
    await mount(tester);
    await tester.tap(find.byTooltip('Attach photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.descendant(
        of: find.byTooltip('Send message'),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    repository.pendingPick!.complete(const ApiSuccess(null));
    await tester.pumpAndSettle();
  });

  testWidgets('awaiting send shows progress inside the send button', (
    tester,
  ) async {
    final pendingSend = Completer<bool>();
    await mount(tester, onSend: (_, _) => pendingSend.future);
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      find.descendant(
        of: find.byTooltip('Send message'),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    pendingSend.complete(true);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'send retains focus and keyboard through sending rebuild and completion',
    (tester) async {
      final pendingSend = Completer<bool>();
      final sending = ValueNotifier(false);
      addTearDown(sending.dispose);
      await mount(
        tester,
        sending: sending,
        onSend: (_, _) => pendingSend.future,
      );
      await tester.enterText(find.byType(TextField), 'Hello');
      final focus = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode;

      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      sending.value = true;
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      sending.value = false;
      pendingSend.complete(true);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(find.text('Hello'), findsNothing);
    },
  );

  testWidgets('keyboard send action sends without closing keyboard', (
    tester,
  ) async {
    final outgoing = <String>[];
    await mount(
      tester,
      onSend: (text, _) async {
        outgoing.add(text);
        return true;
      },
    );
    await tester.enterText(find.byType(TextField), 'Keyboard message');
    final focus = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode;
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(outgoing, ['Keyboard message']);
    expect(focus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets(
    'new draft typed while sending survives previous send completion',
    (tester) async {
      final pendingSend = Completer<bool>();
      final outgoing = <String>[];
      await mount(
        tester,
        onSend: (text, _) {
          outgoing.add(text);
          return pendingSend.future;
        },
      );
      await tester.enterText(find.byType(TextField), 'First message');
      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Next message');
      pendingSend.complete(true);
      await tester.pumpAndSettle();
      expect(outgoing, ['First message']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Next message',
      );
    },
  );

  testWidgets('attachment cleanup retains caption focus and keyboard', (
    tester,
  ) async {
    repository.pendingPick = Completer<ApiResult<ChatAttachment?>>();
    repository.pendingDiscard = Completer<ApiResult<void>>();
    await mount(tester);
    await tester.tap(find.byTooltip('Attach photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    repository.pendingPick!.complete(
      const ApiSuccess(_FakeMediaRepository.voice),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Voice caption');
    final focus = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode;

    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(sent, [_FakeMediaRepository.voice]);
    expect(repository.discards, 1);
    expect(focus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

    repository.pendingDiscard!.complete(const ApiSuccess<void>(null));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });
}
