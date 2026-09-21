import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_join_request_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _requestWithPhoto = JoinRequest(
  id: 'req-1',
  name: 'Omar',
  goal: 'lose weight',
  imageUrl: 'https://res.cloudinary.com/demo/image/upload/client.jpg',
);

const _requestWithoutPhoto = JoinRequest(
  id: 'req-2',
  name: 'Sara',
  goal: 'muscle gain',
);

Future<void> _pumpTile(WidgetTester tester, JoinRequest request) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: CoachJoinRequestTile(
            request: request,
            busy: false,
            actionInFlight: false,
            onAccept: () {},
            onReject: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('CoachJoinRequestTile avatar', () {
    testWidgets('shows the network photo when the API returns one', (
      tester,
    ) async {
      await _pumpTile(tester, _requestWithPhoto);

      // Image.network builds synchronously; the load itself never completes
      // in tests, which is fine — the widget tree is what matters here.
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Omar'), findsOneWidget);
    });

    testWidgets('falls back to the person icon without a photo', (
      tester,
    ) async {
      await _pumpTile(tester, _requestWithoutPhoto);

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
    });
  });
}
