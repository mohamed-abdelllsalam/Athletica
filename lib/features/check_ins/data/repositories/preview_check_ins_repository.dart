import 'dart:io';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Sample data for the explicitly labelled UI preview. Never calls an API,
/// reads real profiles, or persists responses to disk.
class PreviewCheckInsRepository implements CheckInsRepository {
  PreviewCheckInsRepository() {
    for (final entry in _entries) {
      if (entry.answers.isNotEmpty) {
        _coachHistory[entry.id] = [_submissionFor(entry)];
      }
    }
  }

  final Map<String, List<CheckInSubmission>> _coachHistory = {};

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
      submittedAt: DateTime(2026, 9, 23, 9, 30),
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
      submittedAt: DateTime(2026, 9, 23, 9, 30),
      answers: const {
        'weight': '85',
        'average': '85.2',
        'waist': '88',
        'photo': 'No',
        'energy': '6',
      },
    ),
  ];

  bool _hasPending = true;
  final List<CheckInSubmission> _clientHistory = [];

  @override
  Future<ApiResult<List<CheckIn>>> getCheckIns() async =>
      ApiSuccess(List.unmodifiable(_entries));

  @override
  Future<ApiResult<List<CheckInQuestion>>> getQuestions({
    bool coachView = true,
  }) async => ApiSuccess(
    List.unmodifiable(
      coachView || _hasPending ? _questions : <CheckInQuestion>[],
    ),
  );

  @override
  Future<ApiResult<CheckInSubmitResult>> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required Map<String, File> imageFiles,
  }) async {
    final at = DateTime.now();
    final id = 'preview-${at.microsecondsSinceEpoch}';
    _clientHistory.insert(
      0,
      CheckInSubmission(
        id: id,
        submittedAt: at,
        answers: [
          for (final q in questions)
            if (answers[q.id] != null)
              CheckInAnswer(
                id: '$id-${q.id}',
                questionId: q.id,
                answerValue: answers[q.id]!,
                snapshotQuestion: q.label,
                snapshotType: q.type.name,
                snapshotOptions: q.options,
                snapshotRequired: q.required,
                snapshotOrder: q.order,
              ),
        ],
      ),
    );
    _hasPending = false;
    // The preview client is the initially pending sample recipient.
    final index = _entries.indexWhere((entry) => entry.id == 'sample-2');
    final client = _entries[index];
    _entries[index] = CheckIn(
      id: client.id,
      clientName: client.clientName,
      status: CheckInStatus.completed,
      submittedAt: at,
      clientPhotoUrl: client.clientPhotoUrl,
      answers: answers,
    );
    _coachHistory
        .putIfAbsent(client.id, () => [])
        .insert(0, _clientHistory.first);
    return ApiSuccess(CheckInSubmitResult(submissionId: id, submittedAt: at));
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
    _questions = List.unmodifiable(_questions.where((q) => q.id != questionId));
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
  Future<ApiResult<void>> assignCheckin({required String coachClientId}) async {
    final index = _entries.indexWhere((entry) => entry.id == coachClientId);
    if (index < 0) return const ApiError(UnknownFailure('Client not found.'));
    final entry = _entries[index];
    _entries[index] = CheckIn(
      id: entry.id,
      clientName: entry.clientName,
      status: CheckInStatus.pending,
      submittedAt: entry.submittedAt,
      clientPhotoUrl: entry.clientPhotoUrl,
      answers: entry.answers,
    );
    if (coachClientId == 'sample-2') _hasPending = true;
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<List<CheckInSubmission>>> getCoachSubmissions(
    String coachClientId,
  ) async {
    return ApiSuccess(List.unmodifiable(_coachHistory[coachClientId] ?? []));
  }

  @override
  Future<ApiResult<CheckInSubmission>> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  ) async {
    final submissions = await getCoachSubmissions(coachClientId);
    return switch (submissions) {
      ApiError(:final failure) => ApiError(failure),
      ApiSuccess(:final data) =>
        data
                    .where((s) => s.id == submissionId)
                    .cast<CheckInSubmission?>()
                    .firstOrNull ==
                null
            ? const ApiError(UnknownFailure('Check-in not found.'))
            : ApiSuccess(data.firstWhere((s) => s.id == submissionId)),
    };
  }

  @override
  Future<ApiResult<bool>> hasPendingAssignment() async =>
      ApiSuccess(_hasPending);

  @override
  Future<ApiResult<List<CheckInSubmission>>> getClientSubmissions() async {
    return ApiSuccess(List.unmodifiable(_clientHistory));
  }

  @override
  Future<ApiResult<CheckInSubmission>> getClientSubmissionDetail(
    String submissionId,
  ) async {
    final match = _clientHistory.where((s) => s.id == submissionId).firstOrNull;
    return match == null
        ? const ApiError(UnknownFailure('Check-in not found.'))
        : ApiSuccess(match);
  }

  CheckInSubmission _submissionFor(CheckIn entry) => CheckInSubmission(
    id: entry.id,
    submittedAt: entry.submittedAt,
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
