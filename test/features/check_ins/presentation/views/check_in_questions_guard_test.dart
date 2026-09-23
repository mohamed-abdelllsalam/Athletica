import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';
import 'package:athletica/features/check_ins/domain/usecases/assign_check_in_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_ins_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_checkin_pending_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_response_usecase.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _GuardFakeRepository implements CheckInsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected repository call: ${invocation.memberName}',
  );
}

CheckInsCubit _cubit() => CheckInsCubit(
  GetCheckInsUseCase(_GuardFakeRepository()),
  GetCheckInQuestionsUseCase(_GuardFakeRepository()),
  SaveCheckInResponseUseCase(_GuardFakeRepository()),
  SaveCheckInQuestionsUseCase(_GuardFakeRepository()),
  GetCheckinPendingUseCase(_GuardFakeRepository()),
  AssignCheckInUseCase(_GuardFakeRepository()),
  GetCoachSubmissionsUseCase(_GuardFakeRepository()),
  GetCoachSubmissionDetailUseCase(_GuardFakeRepository()),
  GetClientSubmissionsUseCase(_GuardFakeRepository()),
);

const _questions = [
  CheckInQuestion(id: 'q1', label: 'Q1', type: CheckInQuestionType.TEXT),
  CheckInQuestion(id: 'q2', label: 'Q2', type: CheckInQuestionType.TEXT),
];

Widget _host(CheckInsCubit cubit) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, _) => MaterialApp(
    home: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: CheckInQuestionsView(
                  questions: _questions,
                  clients: [
                    CheckIn(
                      id: 'c1',
                      clientName: 'Ali',
                      status: CheckInStatus.notAssigned,
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  ),
);

Future<void> _pumpQuestions(WidgetTester tester, CheckInsCubit cubit) async {
  // Match the ScreenUtil design size so .w/.h units measure 1:1.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(_host(cubit));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _moveSecondQuestionUp(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Actions for Q2'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Move up'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'reordered template shows the unsaved-changes guard on AppBar back',
    (tester) async {
      final cubit = _cubit();
      addTearDown(cubit.close);
      await _pumpQuestions(tester, cubit);

      await _moveSecondQuestionUp(tester);
      expect(
        tester.getTopLeft(find.text('Q2')).dy,
        lessThan(tester.getTopLeft(find.text('Q1')).dy),
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.text('Send Questions'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('clean template pops immediately without the guard', (
    tester,
  ) async {
    final cubit = _cubit();
    addTearDown(cubit.close);
    await _pumpQuestions(tester, cubit);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsNothing);
    expect(find.text('Send Questions'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
