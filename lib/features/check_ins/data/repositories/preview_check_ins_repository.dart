import 'dart:io';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Sample data for the explicitly labelled UI preview. Never calls an API,
/// reads real profiles, or persists responses to disk.
class PreviewCheckInsRepository implements CheckInsRepository {
  List<CheckInQuestion> _questions = const [
    CheckInQuestion(
      id: 'weight',
      label: 'Current Weight?',
      type: CheckInQuestionType.NUMBER,
      required: true,
      order: 1,
    ),
    CheckInQuestion(
      id: 'average',
      label: 'Weekly Average Weight',
      type: CheckInQuestionType.NUMBER,
      required: true,
      order: 2,
    ),
    CheckInQuestion(
      id: 'waist',
      label: 'Waist Measurement',
      type: CheckInQuestionType.NUMBER,
      order: 3,
    ),
    CheckInQuestion(
      id: 'photo',
      label: 'Progress Photo Uploaded?',
      type: CheckInQuestionType.YES_NO,
      options: ['Yes', 'No'],
      order: 4,
    ),
    CheckInQuestion(
      id: 'energy',
      label: 'Energy (1-10)',
      type: CheckInQuestionType.RATING,
      order: 5,
    ),
  ];

  final List<CheckIn> _entries = [
    CheckIn(
      id: 'sample-1',
      clientName: 'Ali Ahmed',
      status: CheckInStatus.completed,
      timeLabel: 'Today, 9:30 AM',
      answers: const {
        'weight': '78',
        'average': '78.5',
        'waist': '82',
        'photo': 'Yes',
        'energy': '7',
      },
    ),
    CheckIn(
      id: 'sample-2',
      clientName: 'Mohamed Ali',
      status: CheckInStatus.pending,
    ),
    CheckIn(
      id: 'sample-3',
      clientName: 'Jamal Ali',
      status: CheckInStatus.completed,
      timeLabel: 'Today, 9:30 AM',
      answers: const {
        'weight': '85',
        'average': '85.2',
        'waist': '88',
        'photo': 'No',
        'energy': '6',
      },
    ),
  ];

  @override
  Future<ApiResult<List<CheckIn>>> getCheckIns() async =>
      ApiSuccess(List.unmodifiable(_entries));

  @override
  Future<ApiResult<List<CheckInQuestion>>> getQuestions({
    bool coachView = true,
  }) async =>
      ApiSuccess(List.unmodifiable(_questions));

  @override
  Future<ApiResult<CheckInSubmitResult>> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required Map<String, File> imageFiles,
  }) async {
    return ApiSuccess(
      CheckInSubmitResult(
        submissionId: 'preview-${DateTime.now().millisecondsSinceEpoch}',
        submittedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ApiResult<CheckInQuestion>> createQuestion({
    required String question,
    required CheckInQuestionType type,
    List<String>? options,
  }) async {
    final created = CheckInQuestion(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      label: question,
      type: type,
      options: options ?? const [],
      order: _questions.length + 1,
    );
    _questions = List.unmodifiable([..._questions, created]);
    return ApiSuccess(created);
  }

  @override
  Future<ApiResult<CheckInQuestion>> updateQuestion({
    required String questionId,
    String? question,
  }) async {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index < 0) {
      return const ApiError(UnknownFailure('Question not found.'));
    }
    final updated = CheckInQuestion(
      id: _questions[index].id,
      label: question ?? _questions[index].label,
      type: _questions[index].type,
      coachId: _questions[index].coachId,
      options: _questions[index].options,
      required: _questions[index].required,
      order: _questions[index].order,
    );
    _questions = List.unmodifiable([
      ..._questions.sublist(0, index),
      updated,
      ..._questions.sublist(index + 1),
    ]);
    return ApiSuccess(updated);
  }

  @override
  Future<ApiResult<void>> deleteQuestion(String questionId) async {
    if (_questions.length <= 1) {
      return const ApiError(
        UnknownFailure('A form needs at least one question.'),
      );
    }
    _questions = List.unmodifiable(
      _questions.where((q) => q.id != questionId),
    );
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<List<CheckInQuestion>>> reorderQuestions(
    List<String> questionIds,
  ) async {
    final byId = {for (final q in _questions) q.id: q};
    if (questionIds.length != _questions.length ||
        !questionIds.every(byId.containsKey)) {
      return const ApiError(
        UnknownFailure('Question order must include all questions.'),
      );
    }
    _questions = List.unmodifiable([
      for (var i = 0; i < questionIds.length; i++)
        CheckInQuestion(
          id: byId[questionIds[i]]!.id,
          label: byId[questionIds[i]]!.label,
          type: byId[questionIds[i]]!.type,
          coachId: byId[questionIds[i]]!.coachId,
          options: byId[questionIds[i]]!.options,
          required: byId[questionIds[i]]!.required,
          order: i + 1,
        ),
    ]);
    return ApiSuccess(List.unmodifiable(_questions));
  }

  @override
  Future<ApiResult<void>> assignCheckin({
    required String coachClientId,
  }) async =>
      const ApiSuccess(null);

  @override
  Future<ApiResult<List<CheckInSubmission>>> getCoachSubmissions(
    String coachClientId,
  ) async {
    final entry = _entries
        .where((e) => e.id == coachClientId)
        .cast<CheckIn?>();
    final match = entry.isEmpty ? null : entry.first;
    if (match == null || match.status != CheckInStatus.completed) {
      return const ApiSuccess([]);
    }
    return ApiSuccess([_submissionFor(match)]);
  }

  @override
  Future<ApiResult<CheckInSubmission>> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  ) async {
    final submissions = await getCoachSubmissions(coachClientId);
    return switch (submissions) {
      ApiError(:final failure) => ApiError(failure),
      ApiSuccess(:final data) => data
          .where((s) => s.id == submissionId)
          .cast<CheckInSubmission?>()
          .firstOrNull == null
          ? const ApiError(UnknownFailure('Check-in not found.'))
          : ApiSuccess(
              data.firstWhere((s) => s.id == submissionId),
            ),
    };
  }

  @override
  Future<ApiResult<bool>> hasPendingAssignment() async => const ApiSuccess(true);

  @override
  Future<ApiResult<List<CheckInSubmission>>> getClientSubmissions() async {
    return ApiSuccess(
      _entries
          .where((e) => e.status == CheckInStatus.completed)
          .map(_submissionFor)
          .toList(),
    );
  }

  CheckInSubmission _submissionFor(CheckIn entry) => CheckInSubmission(
        id: entry.id,
        submittedAt: DateTime.now(),
        clientName: entry.clientName,
        answers: [
          for (final question in _questions)
            if (entry.answers[question.id] != null)
              CheckInAnswer(
                id: '${entry.id}-${question.id}',
                questionId: question.id,
                answerValue: entry.answers[question.id]!,
                snapshotQuestion: question.label,
                snapshotType: question.type.name,
                snapshotOptions: question.options,
                snapshotRequired: question.required,
                snapshotOrder: question.order,
              ),
        ],
      );
}
