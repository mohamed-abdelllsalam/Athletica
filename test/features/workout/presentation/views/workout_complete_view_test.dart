import 'package:athletica/features/workout/presentation/views/workout_complete_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Done returns to the previous screen after animation completes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkoutCompleteView(),
                  ),
                ),
                child: const Text('Open completion'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open completion'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutCompleteView), findsOneWidget);

    // The bundled animation is 150 frames at 60 fps.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutCompleteView), findsNothing);
    expect(find.text('Open completion'), findsOneWidget);
  });
}
