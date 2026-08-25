import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/invite_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const invite = CoachInviteCode(
    code: 'M7UMQ2',
    token: 'M7UMQ2',
    inviteUrl: 'https://app.example.com/invite/M7UMQ2',
    expiresAt: null,
  );

  final expiringInvite = CoachInviteCode(
    code: 'M7UMQ2',
    token: 'M7UMQ2',
    inviteUrl: 'https://app.example.com/invite/M7UMQ2',
    expiresAt: DateTime(2026, 9, 1, 17, 33),
  );

  Future<void> openDialog(WidgetTester tester) async {
    // Match a typical phone so ScreenUtil (.w/.h/.sp) scales like production.
    tester.view.physicalSize = const Size(375, 812) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const InviteCodeDialog(invite: invite),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
  }

  testWidgets(
    'stepping through the reveal keeps every curve within [0, 1]',
    (tester) async {
      await openDialog(tester);

      // Frames sampled mid-reveal — reproduces the easeOutBack overshoot
      // assertion when an overshooting curve is fed into another CurveTween.
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 90));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Copy Code'), findsOneWidget);
      expect(find.text('Regenerate'), findsOneWidget);
    },
  );

  testWidgets('shows expiry date with 12-hour time stamp', (tester) async {
    tester.view.physicalSize = const Size(375, 812) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: InviteCodeDialog(invite: expiringInvite),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expires on 2026-09-01 at 5:33 PM'), findsOneWidget);
  });

  testWidgets('copy code writes the raw code to the clipboard',
      (tester) async {
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<Object?, Object?>;
          clipboardText = args['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await openDialog(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy Code'));
    await tester.pumpAndSettle();

    expect(clipboardText, 'M7UMQ2');
  });
}
