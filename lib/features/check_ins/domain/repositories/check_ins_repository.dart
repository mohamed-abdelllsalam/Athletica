import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';

abstract class CheckInsRepository {
  /// Coach roster from `GET /coach/clients`, mapped to [CheckIn] rows with
  /// [CheckInStatus.unknown]. `id` is `coach_clients.id` (the
  /// `coach_client_id` for assignment).
  Future<ApiResult<List<CheckIn>>> getCheckIns();

  /// Coach form (`C1`) when [coachView] is true, client pending form (`L2`)
  /// otherwise. Client returns `[]` when no assignment is pending.
  Future<ApiResult<List<CheckInQuestion>>> getQuestions({
    bool coachView = true,
  });

  /// Client submit (`L3`). [answers] are trimmed text values keyed by
  /// question UUID; [imageFiles] are picked files keyed by IMAGE question
  /// UUID. Validation lives in the use case; this only transports.
  Future<ApiResult<CheckInSubmitResult>> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required Map<String, File> imageFiles,
  });

  /// Question primitives for the orchestrated template save
  /// (`C2`/`C4`/`C5`/`C3`).
  Future<ApiResult<CheckInQuestion>> createQuestion({
    required String question,
    required CheckInQuestionType type,
    List<String>? options,
  });
  Future<ApiResult<CheckInQuestion>> updateQuestion({
    required String questionId,
    String? question,
  });
  Future<ApiResult<void>> deleteQuestion(String questionId);
  Future<ApiResult<List<CheckInQuestion>>> reorderQuestions(
    List<String> questionIds,
  );

  /// Assign a pending check-in (`C6`). [coachClientId] is `coach_clients.id`.
  Future<ApiResult<void>> assignCheckin({required String coachClientId});

  /// Submission history per client (`C7`), newest first.
  Future<ApiResult<List<CheckInSubmission>>> getCoachSubmissions(
    String coachClientId,
  );

  /// Submission detail (`C8`). Answers keep backend order.
  Future<ApiResult<CheckInSubmission>> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  );

  /// Pending flag (`L1`).
  Future<ApiResult<bool>> hasPendingAssignment();

  /// Own history (`L4`), newest first.
  Future<ApiResult<List<CheckInSubmission>>> getClientSubmissions();
}
