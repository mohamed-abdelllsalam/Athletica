import 'package:athletica/features/check_ins/domain/entities/check_in.dart';

DateTime? _optDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

/// Data model for submissions (CHECK_IN.md §3.2).
///
/// List items carry no `answers`; detail carries `submission.answers`
/// already sorted by `question_snapshot.order` — never re-sort.
class CheckInAnswerModel extends CheckInAnswer {
  const CheckInAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerValue,
    required super.snapshotQuestion,
    required super.snapshotType,
    super.snapshotOptions,
    super.snapshotRequired,
    super.snapshotOrder,
  });

  factory CheckInAnswerModel.fromJson(Map<String, dynamic> json) {
    final snapshot =
        json['question_snapshot'] as Map<String, dynamic>? ?? {};
    final options = (snapshot['options'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();
    return CheckInAnswerModel(
      id: json['id'] as String? ?? '',
      questionId: json['question_id'] as String?,
      answerValue: json['answer_value']?.toString() ?? '',
      snapshotQuestion: snapshot['question'] as String? ?? '',
      snapshotType: snapshot['type']?.toString() ?? '',
      snapshotOptions: options,
      snapshotRequired: snapshot['required'] as bool? ?? true,
      snapshotOrder: (snapshot['order'] as num?)?.toInt() ?? 0,
    );
  }

  CheckInAnswer toEntity() => CheckInAnswer(
        id: id,
        questionId: questionId,
        answerValue: answerValue,
        snapshotQuestion: snapshotQuestion,
        snapshotType: snapshotType,
        snapshotOptions: List.unmodifiable(snapshotOptions),
        snapshotRequired: snapshotRequired,
        snapshotOrder: snapshotOrder,
      );
}

class CheckInSubmissionModel extends CheckInSubmission {
  const CheckInSubmissionModel({
    required super.id,
    required super.submittedAt,
    super.coachId,
    super.coachClientId,
    super.clientId,
    super.clientName,
    super.clientEmail,
    super.answers,
  });

  /// Parses a list item (`{id, submitted_at, ...}`, no answers).
  factory CheckInSubmissionModel.fromListJson(Map<String, dynamic> json) {
    return CheckInSubmissionModel(
      id: json['id'] as String? ?? '',
      submittedAt: _optDate(json['submitted_at']),
      coachId: json['coach_id'] as String? ?? '',
      coachClientId: json['coach_client_id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
    );
  }

  /// Parses a detail body. Accepts either the raw detail map or the full
  /// response envelope (`{submission: {...}}`).
  factory CheckInSubmissionModel.fromDetailJson(Map<String, dynamic> json) {
    final root = json['submission'] is Map<String, dynamic>
        ? json['submission'] as Map<String, dynamic>
        : json;
    final client = root['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    final answers = (root['answers'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CheckInAnswerModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return CheckInSubmissionModel(
      id: root['id'] as String? ?? '',
      submittedAt: _optDate(root['submitted_at']),
      coachId: root['coach_id'] as String? ?? '',
      coachClientId: root['coach_client_id'] as String? ?? '',
      clientId: root['client_id'] as String? ?? '',
      clientName: (user['username'] ?? user['name'] ?? '') as String,
      clientEmail: (user['email'] ?? '') as String,
      answers: answers,
    );
  }

  CheckInSubmission toEntity() => CheckInSubmission(
        id: id,
        submittedAt: submittedAt,
        coachId: coachId,
        coachClientId: coachClientId,
        clientId: clientId,
        clientName: clientName,
        clientEmail: clientEmail,
        answers: List.unmodifiable(answers),
      );
}
