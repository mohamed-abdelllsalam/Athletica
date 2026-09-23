import 'dart:async';
import 'dart:io';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';
import 'package:athletica/features/check_ins/domain/usecases/assign_check_in_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_ins_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_checkin_pending_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_response_usecase.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_history_cubit.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_submission_cubit.dart';
import 'package:athletica/features/check_ins/presentation/models/check_in_preview_role.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/client_preview.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCheckInsRepository implements CheckInsRepository {
  ApiResult<bool> pending = const ApiSuccess(true);
  ApiResult<List<CheckInSubmission>> history = const ApiSuccess([]);
  ApiResult<CheckInSubmission> detail = const ApiSuccess(
    CheckInSubmission(id: 'submission-1', submittedAt: null),
  );
  final assigned = <String>[];
  final detailRequests = <String>[];
  int rosterReads = 0;
  int pendingReads = 0;
  int historyReads = 0;
  int questionReads = 0;
  List<CheckInQuestion> questions = const [];
  Completer<ApiResult<CheckInSubmitResult>>? submitCompleter;
  String? failAssignment;
  @override
  Future<ApiResult<List<CheckIn>>> getCheckIns() async {
    rosterReads++;
    return ApiSuccess([
      for (final id in ['one', 'two'])
        CheckIn(
          id: id,
          clientName: id,
          status: assigned.contains(id)
              ? CheckInStatus.pending
              : CheckInStatus.notAssigned,
        ),
    ]);
  }

  @override
  Future<ApiResult<bool>> hasPendingAssignment() async {
    pendingReads++;
    return pending;
  }

  @override
  Future<ApiResult<List<CheckInQuestion>>> getQuestions({
    bool coachView = true,
  }) async {
    questionReads++;
    return ApiSuccess(questions);
  }

  @override
  Future<ApiResult<List<CheckInSubmission>>> getClientSubmissions() async {
    historyReads++;
    return history;
  }

  @override
  Future<ApiResult<List<CheckInSubmission>>> getCoachSubmissions(
    String coachClientId,
  ) async => history;
  @override
  Future<ApiResult<void>> assignCheckin({required String coachClientId}) async {
    if (coachClientId == failAssignment) {
      return const ApiError(NetworkFailure('Assignment failed'));
    }
    assigned.add(coachClientId);
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<CheckInSubmitResult>> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required Map<String, File> imageFiles,
  }) async {
    if (submitCompleter != null) return submitCompleter!.future;
    pending = const ApiSuccess(false);
    history = const ApiSuccess([
      CheckInSubmission(id: 'new-submission', submittedAt: null),
    ]);
    return const ApiSuccess(
      CheckInSubmitResult(submissionId: 'new-submission'),
    );
  }

  @override
  Future<ApiResult<CheckInSubmission>> getClientSubmissionDetail(
    String submissionId,
  ) async {
    detailRequests.add('client/$submissionId');
    return detail;
  }

  @override
  Future<ApiResult<CheckInSubmission>> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  ) async {
    detailRequests.add('coach/$coachClientId/$submissionId');
    return detail;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected repository call: ${invocation.memberName}',
  );
}

void main() {
  late FakeCheckInsRepository repository;
  late CheckInsCubit cubit;
  setUp(() {
    repository = FakeCheckInsRepository();
    cubit = CheckInsCubit(
      GetCheckInsUseCase(repository),
      GetCheckInQuestionsUseCase(repository),
      SaveCheckInResponseUseCase(repository),
      SaveCheckInQuestionsUseCase(repository),
      GetCheckinPendingUseCase(repository),
      AssignCheckInUseCase(repository),
      GetCoachSubmissionsUseCase(repository),
      GetCoachSubmissionDetailUseCase(repository),
      GetClientSubmissionsUseCase(repository),
    );
  });
  tearDown(() => cubit.close());
  testWidgets('coach opens selected history entry as read-only answers', (
    tester,
  ) async {
    repository.history = const ApiSuccess([
      CheckInSubmission(id: 'selected', submittedAt: null),
    ]);
    repository.detail = const ApiSuccess(
      CheckInSubmission(
        id: 'selected',
        submittedAt: null,
        answers: [
          CheckInAnswer(
            id: 'answer',
            questionId: null,
            answerValue: 'Historical answer',
            snapshotQuestion: 'Historical question',
            snapshotType: 'TEXT',
          ),
        ],
      ),
    );
    sl.registerFactory<CheckInHistoryCubit>(
      () => CheckInHistoryCubit(GetCoachSubmissionsUseCase(repository)),
    );
    sl.registerFactory<CheckInSubmissionCubit>(
      () => CheckInSubmissionCubit(
        GetCoachSubmissionDetailUseCase(repository),
        GetClientSubmissionDetailUseCase(repository),
      ),
    );
    addTearDown(sl.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => const MaterialApp(
          home: CheckInHistoryView(
            coachClientId: 'relation',
            clientName: 'Alex',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(repository.detailRequests, ['coach/relation/selected']);
    expect(find.text('Check-in Answers'), findsOneWidget);
    expect(find.text('Historical question'), findsOneWidget);
    expect(find.text('Historical answer'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'client pending form keeps history below it without layout overflow',
    (tester) async {
      repository.questions = const [
        CheckInQuestion(
          id: 'question',
          label: 'How was your week?',
          type: CheckInQuestionType.TEXT,
        ),
      ];
      await cubit.load(role: CheckInPreviewRole.client);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const ClientPreview(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('How was your week?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('History'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.getTopLeft(find.text('History')).dy,
        greaterThan(tester.getTopLeft(find.text('How was your week?')).dy),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  test(
    'pending request error surfaces and retry restores pending state',
    () async {
      repository.pending = const ApiError(NetworkFailure('Offline'));
      await cubit.load(role: CheckInPreviewRole.client);
      expect((cubit.state as CheckInsError).message, 'Offline');
      repository.pending = const ApiSuccess(true);
      await cubit.refresh();
      expect((cubit.state as CheckInsReady).hasPending, isTrue);
    },
  );
  test(
    'partial assignment refreshes successful clients before reporting failure',
    () async {
      repository.failAssignment = 'two';
      await cubit.load();
      expect(await cubit.assignCheckins(['one', 'two']), isFalse);
      final ready = cubit.state as CheckInsReady;
      expect(ready.entries.first.status, CheckInStatus.pending);
      expect(ready.entries.last.status, CheckInStatus.notAssigned);
      expect(ready.message, 'Assignment failed');
      expect(repository.rosterReads, 2);
    },
  );
  test('successful assignment reloads roster status', () async {
    await cubit.load();
    expect(await cubit.assignCheckins(['one']), isTrue);
    expect(
      (cubit.state as CheckInsReady).entries.first.status,
      CheckInStatus.pending,
    );
  });
  test(
    'submit clears pending form and reloads complete history objects',
    () async {
      await cubit.load(role: CheckInPreviewRole.client);
      expect(await cubit.saveResponse(questions: [], answers: {}), isTrue);
      final ready = cubit.state as CheckInsReady;
      expect(ready.hasPending, isFalse);
      expect(ready.questions, isEmpty);
      expect(ready.clientStatus, CheckInStatus.completed);
      expect(
        (ready.history as ApiSuccess<List<CheckInSubmission>>).data.single.id,
        'new-submission',
      );
      expect(repository.pendingReads, 2);
      expect(repository.historyReads, 2);
    },
  );
  test(
    'history failure does not hide pending form and retries independently',
    () async {
      repository.history = const ApiError(NetworkFailure('History offline'));
      await cubit.load(role: CheckInPreviewRole.client);
      expect((cubit.state as CheckInsReady).hasPending, isTrue);
      expect((cubit.state as CheckInsReady).history, isA<ApiError>());
      repository.history = const ApiSuccess([]);
      await cubit.reloadClientHistory();
      expect((cubit.state as CheckInsReady).history, isA<ApiSuccess>());
      expect(repository.pendingReads, 1);
    },
  );
  test('no pending assignment retains historical submissions', () async {
    repository.pending = const ApiSuccess(false);
    repository.history = const ApiSuccess([
      CheckInSubmission(id: 'old', submittedAt: null),
    ]);
    await cubit.load(role: CheckInPreviewRole.client);
    final ready = cubit.state as CheckInsReady;
    expect(ready.clientStatus, CheckInStatus.completed);
    expect(
      (ready.history as ApiSuccess<List<CheckInSubmission>>).data.single.id,
      'old',
    );
  });
  test(
    'refresh during submit preserves saving guard and blocks duplicate submit',
    () async {
      await cubit.load(role: CheckInPreviewRole.client);
      repository.submitCompleter = Completer<ApiResult<CheckInSubmitResult>>();
      final saving = cubit.saveResponse(questions: [], answers: {});
      await cubit.refresh();
      expect((cubit.state as CheckInsReady).saving, isTrue);
      expect(await cubit.saveResponse(questions: [], answers: {}), isFalse);
      expect(repository.pendingReads, 1);
      repository.submitCompleter!.complete(
        const ApiError(NetworkFailure('Offline')),
      );
      await saving;
    },
  );
  test('coach history exposes failure then retry results', () async {
    final historyCubit = CheckInHistoryCubit(
      GetCoachSubmissionsUseCase(repository),
    );
    addTearDown(historyCubit.close);
    repository.history = const ApiError(NetworkFailure('Offline'));
    await historyCubit.load('one');
    expect(historyCubit.state, isA<ApiError>());
    repository.history = const ApiSuccess([
      CheckInSubmission(id: 'old', submittedAt: null),
    ]);
    await historyCubit.load('one');
    expect(
      (historyCubit.state as ApiSuccess<List<CheckInSubmission>>)
          .data
          .single
          .id,
      'old',
    );
  });
  for (final coach in [false, true]) {
    test(
      '${coach ? 'coach' : 'client'} detail selects the correct endpoint use case',
      () async {
        final detailCubit = CheckInSubmissionCubit(
          GetCoachSubmissionDetailUseCase(repository),
          GetClientSubmissionDetailUseCase(repository),
        );
        addTearDown(detailCubit.close);
        await detailCubit.load(
          coachClientId: coach ? 'one' : null,
          submissionId: 'selected',
        );
        expect(repository.detailRequests, [
          coach ? 'coach/one/selected' : 'client/selected',
        ]);
        expect(detailCubit.state, isA<ApiSuccess<CheckInSubmission>>());
      },
    );
  }
}
