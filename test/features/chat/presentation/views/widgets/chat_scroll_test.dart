import 'dart:async';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/domain/entities/chat_attachment.dart';
import 'package:athletica/core/widgets/chat_media_bubble.dart';
import 'package:athletica/core/presentation/cubits/chat_draft_cubit.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_state.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_view_body.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart'
    as coach;
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_chat_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ChatCubit extends Cubit<ChatState> implements ChatCubit {
  _ChatCubit(super.initialState);
  int olderRequests = 0;
  Completer<bool>? pendingSend;
  @override
  Future<bool> send(String rawContent, {ChatAttachment? attachment}) async =>
      pendingSend == null ? true : await pendingSend!.future;
  void publish(ChatState value) => emit(value);
  @override
  Future<void> loadOlder() async {
    olderRequests++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoachCubit extends Cubit<ClientCoachState> implements ClientCoachCubit {
  _CoachCubit() : super(ClientCoachInitial());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DraftCubit extends Cubit<ChatDraftState> implements ChatDraftCubit {
  _DraftCubit() : super(const ChatDraftState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<ChatMessage> _messages(int start, int count) => List.generate(count, (i) {
  final number = start + i;
  return ChatMessage(
    id: 'message-$number',
    conversationId: 'conversation',
    senderUserId: 'other',
    senderRole: 'CLIENT',
    content: 'Message $number${'\nMore detail' * (number % 5)}',
    createdAt: DateTime(2026, 1, 1).add(Duration(minutes: number)),
  );
});

ChatReady _ready(
  List<ChatMessage> messages, {
  bool hasMore = false,
  bool loadingOlder = false,
  bool canSend = false,
}) => ChatReady(
  messages: messages,
  conversationId: 'conversation',
  canSend: canSend,
  hasMore: hasMore,
  isLoadingOlder: loadingOlder,
  isSending: false,
  realtimeAvailable: false,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'client_id': 'self'});
    await sl.reset();
    sl.registerFactory<ChatDraftCubit>(_DraftCubit.new);
  });
  tearDown(() async => sl.reset());

  Future<void> mount(
    WidgetTester tester,
    _ChatCubit cubit,
    bool isCoach,
  ) async {
    final coachCubit = _CoachCubit();
    addTearDown(coachCubit.close);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ChatCubit>.value(value: cubit),
              BlocProvider<ClientCoachCubit>.value(value: coachCubit),
            ],
            child: isCoach
                ? const CoachChatViewBody(
                    contact: coach.ChatContact(id: 'client', name: 'Client'),
                    chatArgs: CoachChatRouteArgs(
                      clientId: 'client',
                      clientName: 'Client',
                      conversationId: 'conversation',
                    ),
                  )
                : const ChatViewBody(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void expectVisible(WidgetTester tester, String id) {
    final message = find.byWidgetPredicate(
      (widget) =>
          widget is ChatMediaBubble &&
          widget.content ==
              _messages(int.parse(id.split('-').last), 1).first.content,
    );
    expect(message, findsOneWidget);
    final viewport = tester.getRect(find.byType(ListView));
    final bubble = tester.getRect(message);
    expect(bubble.top, greaterThanOrEqualTo(viewport.top));
    expect(bubble.bottom, lessThanOrEqualTo(viewport.bottom));
  }

  for (final isCoach in [false, true]) {
    final name = isCoach ? 'coach' : 'athlete';
    testWidgets('$name repeated send taps keep keyboard open while sending', (
      tester,
    ) async {
      final cubit = _ChatCubit(_ready(_messages(0, 1), canSend: true));
      cubit.pendingSend = Completer<bool>();
      await mount(tester, cubit, isCoach);
      await tester.enterText(find.byType(TextField), 'Message');
      final focus = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode;
      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      cubit.pendingSend!.complete(true);
      await tester.pumpAndSettle();
    });
    testWidgets('$name dismisses keyboard when chat background is tapped', (
      tester,
    ) async {
      await mount(
        tester,
        _ChatCubit(_ready(_messages(0, 1), canSend: true)),
        isCoach,
      );
      await tester.enterText(find.byType(TextField), 'Draft');
      final focus = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode;
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.tapAt(
        tester.getRect(find.byType(ListView)).topLeft + const Offset(20, 20),
      );
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });
    testWidgets(
      '$name opens an already loaded long chat at the latest message',
      (tester) async {
        await mount(tester, _ChatCubit(_ready(_messages(0, 80))), isCoach);
        expectVisible(tester, 'message-79');
      },
    );

    testWidgets('$name shows the latest message on the first history frame', (
      tester,
    ) async {
      final cubit = _ChatCubit(const ChatLoading());
      await mount(tester, cubit, isCoach);
      cubit.publish(_ready(_messages(0, 80)));
      await tester.pump();
      expectVisible(tester, 'message-79');
    });

    testWidgets(
      '$name preserves the visible history when older messages arrive',
      (tester) async {
        final cubit = _ChatCubit(_ready(_messages(40, 40), hasMore: true));
        await mount(tester, cubit, isCoach);
        final list = tester.widget<ListView>(find.byType(ListView));
        list.controller!.jumpTo(list.controller!.position.maxScrollExtent);
        await tester.pump();
        expect(cubit.olderRequests, greaterThan(0));
        final before = tester.getTopLeft(
          find.byWidgetPredicate(
            (widget) =>
                widget is ChatMediaBubble &&
                widget.content == _messages(40, 1).first.content,
          ),
        );
        cubit.publish(
          _ready(_messages(40, 40), hasMore: true, loadingOlder: true),
        );
        await tester.pump();
        cubit.publish(_ready(_messages(0, 80)));
        await tester.pump();
        await tester.pump();
        expect(
          tester
              .getTopLeft(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is ChatMediaBubble &&
                      widget.content == _messages(40, 1).first.content,
                ),
              )
              .dy,
          closeTo(before.dy, 1),
        );
      },
    );

    testWidgets(
      '$name does not pull a history reader down for incoming messages',
      (tester) async {
        final cubit = _ChatCubit(_ready(_messages(0, 80)));
        await mount(tester, cubit, isCoach);
        final list = tester.widget<ListView>(find.byType(ListView));
        list.controller!.jumpTo(1000);
        await tester.pump();
        final viewport = tester.getRect(find.byType(ListView));
        final visible = find.byType(ChatMediaBubble).evaluate().firstWhere((
          element,
        ) {
          final rect = tester.getRect(find.byWidget(element.widget));
          return rect.top >= viewport.top && rect.bottom <= viewport.bottom;
        }).widget;
        final anchor = find.byWidgetPredicate(
          (widget) => widget is ChatMediaBubble && widget.key == visible.key,
        );
        final before = tester.getTopLeft(anchor).dy;
        cubit.publish(_ready(_messages(0, 81)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.getTopLeft(anchor).dy, closeTo(before, 1));
        expect(
          find.text(_messages(80, 1).first.content!).hitTestable(),
          findsNothing,
        );
      },
    );
  }
}
