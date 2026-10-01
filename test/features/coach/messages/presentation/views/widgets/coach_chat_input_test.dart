import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_chat_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final keyboardSend in [false, true]) {
    testWidgets(
      'coach input ${keyboardSend ? 'keyboard action' : 'send tap'} keeps keyboard open',
      (tester) async {
        final sent = <String>[];
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, _) => MaterialApp(
              home: UnfocusOnTap(
                child: Scaffold(
                  bottomNavigationBar: CoachChatInput(onSend: sent.add),
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'Hello coach');
        await tester.pump();
        final focus = tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode;
        if (keyboardSend) {
          await tester.testTextInput.receiveAction(TextInputAction.send);
        } else {
          await tester.tap(find.byIcon(Icons.send_rounded));
        }
        await tester.pumpAndSettle();
        expect(sent, ['Hello coach']);
        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
      },
    );
  }
}
