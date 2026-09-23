import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/data/datasources/check_ins_remote_data_source.dart';
import 'package:athletica/features/check_ins/data/repositories/check_ins_repository_impl.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_clients_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late CheckInsRepositoryImpl repository;
  late Map<String, Object> responses;
  late List<String> requests;
  setUp(() {
    requests = [];
    responses = {
      'coach/clients': {
        'clients': [
          {
            'id': 'relation-1',
            'client': {
              'id': 'profile-1',
              'user': {'name': 'Alex'},
            },
          },
        ],
      },
      'coach/checkin/clients/relation-1/status': {
        'has_pending': false,
        'answered': true,
        'submissions_count': 2,
        'last_submitted_at': '2026-09-23T12:05:00Z',
      },
    };
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options.path);
          final body = responses[options.path];
          if (body is DioExceptionType) {
            handler.reject(DioException(requestOptions: options, type: body));
          } else if (body == null) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Unexpected request ${options.path}',
              ),
            );
          } else {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: body),
            );
          }
        },
      ),
    );
    repository = CheckInsRepositoryImpl(
      CheckInsRemoteDataSourceImpl(dio),
      CoachClientsRemoteDataSourceImpl(dio),
    );
  });
  tearDown(() => dio.close(force: true));

  test(
    'roster uses relation ID to fetch authoritative status and time',
    () async {
      final result = await repository.getCheckIns();
      final entry = (result as ApiSuccess<List<CheckIn>>).data.single;
      expect(requests, [
        'coach/clients',
        'coach/checkin/clients/relation-1/status',
      ]);
      expect(entry.id, 'relation-1');
      expect(entry.clientName, 'Alex');
      expect(entry.status, CheckInStatus.completed);
      expect(entry.submittedAt, DateTime.utc(2026, 9, 23, 12, 5));
    },
  );
  test(
    'status network failure becomes typed failure instead of not assigned',
    () async {
      responses['coach/checkin/clients/relation-1/status'] =
          DioExceptionType.connectionError;
      final result = await repository.getCheckIns();
      expect((result as ApiError).failure, isA<NetworkFailure>());
    },
  );
  test('malformed status becomes failure instead of invented status', () async {
    responses['coach/checkin/clients/relation-1/status'] = <String, dynamic>{};
    expect(await repository.getCheckIns(), isA<ApiError>());
  });
  test('never submitted roster preserves missing timestamp', () async {
    responses['coach/checkin/clients/relation-1/status'] = {
      'has_pending': false,
      'answered': false,
      'submissions_count': 0,
      'last_submitted_at': null,
    };
    final result = await repository.getCheckIns() as ApiSuccess<List<CheckIn>>;
    expect(result.data.single.status, CheckInStatus.notAssigned);
    expect(result.data.single.submittedAt, isNull);
  });
  for (final coach in [false, true]) {
    test(
      '${coach ? 'coach' : 'client'} detail preserves deleted snapshots and server answer order',
      () async {
        final path = coach
            ? 'coach/checkin/clients/relation-1/submissions/submission-1'
            : 'client/checkin/submissions/submission-1';
        responses[path] = {
          'submission': {
            'id': 'submission-1',
            'submitted_at': '2026-09-23T12:05:00Z',
            'answers': [
              {
                'id': 'answer-1',
                'question_id': null,
                'answer_value': 'Historical answer',
                'question_snapshot': {
                  'question': 'Deleted question',
                  'type': 'TEXT',
                  'order': 9,
                },
              },
              {
                'id': 'answer-2',
                'question_id': 'photo',
                'answer_value': 'https://example.com/photo.png',
                'question_snapshot': {
                  'question': 'Progress photo',
                  'type': 'IMAGE',
                  'order': 1,
                },
              },
            ],
          },
        };
        final result = coach
            ? await repository.getCoachSubmissionDetail(
                'relation-1',
                'submission-1',
              )
            : await repository.getClientSubmissionDetail('submission-1');
        final detail = (result as ApiSuccess<CheckInSubmission>).data;
        expect(requests, [path]);
        expect(detail.answers.map((answer) => answer.id), [
          'answer-1',
          'answer-2',
        ]);
        expect(detail.answers.first.questionId, isNull);
        expect(detail.answers.first.snapshotQuestion, 'Deleted question');
        expect(detail.answers.last.snapshotType, 'IMAGE');
        expect(
          detail.answers.last.answerValue,
          'https://example.com/photo.png',
        );
      },
    );
  }
  test('client detail maps request errors to a typed failure', () async {
    responses['client/checkin/submissions/submission-1'] =
        DioExceptionType.connectionError;
    final result = await repository.getClientSubmissionDetail('submission-1');
    expect((result as ApiError).failure, isA<NetworkFailure>());
  });
}
