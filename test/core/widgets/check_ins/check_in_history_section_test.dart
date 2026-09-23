import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/check_ins/check_in_history_section.dart';
import 'package:athletica/core/widgets/check_ins/check_in_submission_answers.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_client_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, _) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('history shows a loading indicator', (tester) async {
    await tester.pumpWidget(
      host(CheckInHistorySection(result: null, onRetry: () {}, onOpen: (_) {})),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('empty history explicitly says no submissions', (tester) async {
    await tester.pumpWidget(
      host(
        CheckInHistorySection(
          result: const ApiSuccess([]),
          onRetry: () {},
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.text('No submitted check-ins yet.'), findsOneWidget);
  });
  testWidgets('history error retry invokes callback', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      host(
        CheckInHistorySection(
          result: const ApiError(NetworkFailure('Offline')),
          onRetry: () => retried = true,
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Retry history'));
    expect(retried, isTrue);
  });
  testWidgets('opening history preserves selected full submission', (
    tester,
  ) async {
    final submission = CheckInSubmission(
      id: 'selected',
      submittedAt: DateTime(2026, 9, 23, 15, 5),
      coachClientId: 'relation',
    );
    CheckInSubmission? opened;
    await tester.pumpWidget(
      host(
        CheckInHistorySection(
          result: ApiSuccess([submission]),
          onRetry: () {},
          onOpen: (item) => opened = item,
        ),
      ),
    );
    expect(find.text('23 Sep 2026, 3:05 PM'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    expect(opened, same(submission));
  });
  testWidgets(
    'historical deleted questions render in server order and remain read only',
    (tester) async {
      await tester.pumpWidget(
        host(
          const CheckInSubmissionAnswers(
            submission: CheckInSubmission(
              id: 'old',
              submittedAt: null,
              answers: [
                CheckInAnswer(
                  id: 'first',
                  questionId: null,
                  answerValue: 'Old answer',
                  snapshotQuestion: 'Deleted question',
                  snapshotType: 'TEXT',
                  snapshotOrder: 9,
                ),
                CheckInAnswer(
                  id: 'second',
                  questionId: 'live',
                  answerValue: 'Second answer',
                  snapshotQuestion: 'Second question',
                  snapshotType: 'TEXT',
                  snapshotOrder: 1,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Deleted question'), findsOneWidget);
      expect(find.text('Old answer'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Deleted question')).dy,
        lessThan(tester.getTopLeft(find.text('Second question')).dy),
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.textContaining('Submit'), findsNothing);
    },
  );
  testWidgets('historical photo uses snapshot image URL and description', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const CheckInSubmissionAnswers(
          submission: CheckInSubmission(
            id: 'old',
            submittedAt: null,
            answers: [
              CheckInAnswer(
                id: 'photo',
                questionId: null,
                answerValue: 'https://example.com/progress.png',
                snapshotQuestion: 'Progress photo',
                snapshotType: 'IMAGE',
              ),
            ],
          ),
        ),
      ),
    );
    final photo = tester.widget<Image>(find.byType(Image));
    expect(
      (photo.image as NetworkImage).url,
      'https://example.com/progress.png',
    );
    expect(photo.semanticLabel, 'Progress photo');
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'unassigned roster hides missing time and provides History action',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        host(
          CheckInClientCard(
            entry: CheckIn(
              id: 'one',
              clientName: 'Alex',
              status: CheckInStatus.notAssigned,
            ),
            onView: () => opened = true,
            onSend: () {},
          ),
        ),
      );
      expect(find.text('● Not assigned'), findsOneWidget);
      expect(find.text('Last submitted'), findsNothing);
      expect(find.text('—'), findsNothing);
      expect(find.text('Time unavailable'), findsNothing);
      await tester.tap(find.text('History'));
      expect(opened, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('completed roster labels and formats last submission', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        CheckInClientCard(
          entry: CheckIn(
            id: 'one',
            clientName: 'Alex',
            status: CheckInStatus.completed,
            submittedAt: DateTime(2026, 9, 23, 15, 5),
          ),
          onView: () {},
          onSend: () {},
        ),
      ),
    );
    expect(find.text('Last submitted'), findsOneWidget);
    expect(find.text('23 Sep 2026, 3:05 PM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
