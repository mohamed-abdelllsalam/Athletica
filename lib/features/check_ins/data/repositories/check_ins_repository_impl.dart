import 'dart:io';

import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/data/datasources/check_ins_remote_data_source.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_clients_remote_data_source.dart';
import 'package:dio/dio.dart';

/// Boundary: catches Dio errors here and maps to typed failures.
/// Never lets raw exceptions leak into domain/presentation.
class CheckInsRepositoryImpl implements CheckInsRepository {
  const CheckInsRepositoryImpl(this._dataSource, this._clientsDataSource);

  final CheckInsRemoteDataSource _dataSource;
  final CoachClientsRemoteDataSource _clientsDataSource;

  Future<ApiResult<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return ApiSuccess(await run());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CheckIn>>> getCheckIns() => _guard(() async {
    final clients = await _clientsDataSource.getAssignedClients();
    final entries = <CheckIn>[];
    // Bound concurrent requests while enriching the roster with authoritative status.
    for (var start = 0; start < clients.length; start += 6) {
      final batch = clients.skip(start).take(6);
      entries.addAll(
        await Future.wait(
          batch.map((client) async {
            final status = await _dataSource.getCoachClientStatus(
              client.relationId,
            );
            return CheckIn(
              id: client.relationId,
              clientName: client.name,
              status: status.status,
              submittedAt: status.lastSubmittedAt,
              clientPhotoUrl: client.profileImage,
            );
          }),
        ),
      );
    }
    return entries;
  });

  @override
  Future<ApiResult<List<CheckInQuestion>>> getQuestions({
    bool coachView = true,
  }) => _guard(() async {
    final models = coachView
        ? await _dataSource.getCoachQuestions()
        : await _dataSource.getClientQuestions();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  Future<ApiResult<CheckInSubmitResult>> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required Map<String, File> imageFiles,
  }) async {
    try {
      final textAnswers = <Map<String, String>>[];
      for (final question in questions) {
        if (question.type == CheckInQuestionType.IMAGE) continue;
        final value = answers[question.id]?.trim() ?? '';
        if (value.isEmpty) continue;
        textAnswers.add({'question_id': question.id, 'answer_value': value});
      }
      final result = await _dataSource.submitCheckin(
        textAnswers: textAnswers,
        imageFiles: imageFiles,
      );
      return ApiSuccess(result);
    } on DioException catch (e) {
      // Only the submit path maps 403 here: besides an impossible wrong-role
      // call, the contract's sole submit 403 is `checkin_no_pending_assignment`
      // (one-shot assignment already consumed). Never applied globally.
      if (e.response?.statusCode == 403) {
        return ApiError(CheckinNoPendingFailure(mapDioException(e).message));
      }
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<CheckInQuestion>> createQuestion({
    required String question,
    required CheckInQuestionType type,
    List<String>? options,
  }) => _guard(
    () async => (await _dataSource.createCoachQuestion(
      question: question,
      type: type.name,
      options: options,
    )).toEntity(),
  );

  @override
  Future<ApiResult<CheckInQuestion>> updateQuestion({
    required String questionId,
    String? question,
  }) => _guard(
    () async => (await _dataSource.updateCoachQuestion(
      questionId,
      question: question,
    )).toEntity(),
  );

  @override
  Future<ApiResult<void>> deleteQuestion(String questionId) =>
      _guard(() async => _dataSource.deleteCoachQuestion(questionId));

  @override
  Future<ApiResult<List<CheckInQuestion>>> reorderQuestions(
    List<String> questionIds,
  ) => _guard(
    () async => (await _dataSource.reorderCoachQuestions(
      questionIds,
    )).map((m) => m.toEntity()).toList(),
  );

  @override
  Future<ApiResult<void>> assignCheckin({required String coachClientId}) =>
      _guard(
        () async => _dataSource.assignCheckin(coachClientId: coachClientId),
      );

  @override
  Future<ApiResult<List<CheckInSubmission>>> getCoachSubmissions(
    String coachClientId,
  ) => _guard(
    () async => (await _dataSource.getCoachSubmissions(
      coachClientId,
    )).map((m) => m.toEntity()).toList(),
  );

  @override
  Future<ApiResult<CheckInSubmission>> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  ) => _guard(
    () async => (await _dataSource.getCoachSubmissionDetail(
      coachClientId,
      submissionId,
    )).toEntity(),
  );

  @override
  Future<ApiResult<bool>> hasPendingAssignment() =>
      _guard(() async => _dataSource.hasPendingAssignment());

  @override
  Future<ApiResult<List<CheckInSubmission>>> getClientSubmissions() => _guard(
    () async => (await _dataSource.getClientSubmissions())
        .map((m) => m.toEntity())
        .toList(),
  );

  @override
  Future<ApiResult<CheckInSubmission>> getClientSubmissionDetail(
    String submissionId,
  ) => _guard(
    () async =>
        (await _dataSource.getClientSubmissionDetail(submissionId)).toEntity(),
  );
}
