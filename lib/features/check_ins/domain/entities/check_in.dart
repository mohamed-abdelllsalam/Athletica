// ignore_for_file: constant_identifier_names
/// Check-in domain entities (documented contract: CHECK_IN.md §3).
/// Enum values intentionally match the backend's uppercase question types.
///
/// [CheckIn] is the coach roster row (a client that can receive an
/// assignment) or a client submission-history row. The backend exposes no
/// coach-side pending status, so roster rows use [CheckInStatus.unknown`.
/// Never infer pending/completed from submission history.
enum CheckInStatus { completed, pending, unknown }

/// Backend question types (CHECK_IN.md §3.1). Serialized uppercase.
enum CheckInQuestionType { NUMBER, TEXT, SINGLE_CHOICE, YES_NO, RATING, IMAGE }

class CheckInQuestion {
  const CheckInQuestion({
    required this.id,
    required this.label,
    required this.type,
    this.coachId = '',
    this.options = const [],
    this.required = true,
    this.order = 0,
  });

  /// Backend `id` (UUID).
  final String id;

  /// Backend `question` text (1–500 chars).
  final String label;
  final CheckInQuestionType type;

  /// Backend `coach_id`.
  final String coachId;

  /// Backend `options` (choice types need ≥2 non-empty).
  final List<String> options;

  /// Backend `required`.
  final bool required;

  /// Backend `order` (positive int, unique ordering via reorder endpoint).
  final int order;
}

class CheckIn {
  CheckIn({
    required this.id,
    required this.clientName,
    required this.status,
    this.timeLabel = '—',
    Map<String, String> answers = const {},
  }) : answers = Map.unmodifiable(answers);

  /// Coach roster rows: `coach_clients.id` (the `coach_client_id` used by
  /// `POST /coach/checkin/assign`). Submission rows: `submission.id`.
  final String id;
  final String clientName;
  final CheckInStatus status;

  /// Display only; no backend time exists for roster rows.
  final String timeLabel;

  /// Answers keyed by question UUID (form state / detail values).
  final Map<String, String> answers;

  CheckIn withResponse({required Map<String, String> answers}) => CheckIn(
        id: id,
        clientName: clientName,
        status: CheckInStatus.completed,
        timeLabel: 'Preview response',
        answers: answers,
      );
}

/// A submitted check-in with historical answers (CHECK_IN.md §3.2).
///
/// [answers] arrive sorted by `question_snapshot.order` — render in array
/// order, never re-sort.
class CheckInSubmission {
  const CheckInSubmission({
    required this.id,
    required this.submittedAt,
    this.coachId = '',
    this.coachClientId = '',
    this.clientId = '',
    this.clientName = '',
    this.clientEmail = '',
    this.answers = const [],
  });

  final String id;
  final DateTime? submittedAt;
  final String coachId;
  final String coachClientId;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final List<CheckInAnswer> answers;
}

/// One historical answer. [questionId] is null when the question was deleted
/// after submit — fall back to the snapshot text.
class CheckInAnswer {
  const CheckInAnswer({
    required this.id,
    required this.questionId,
    required this.answerValue,
    required this.snapshotQuestion,
    required this.snapshotType,
    this.snapshotOptions = const [],
    this.snapshotRequired = true,
    this.snapshotOrder = 0,
  });

  final String id;
  final String? questionId;

  /// For IMAGE answers this is a Cloudinary HTTPS URL.
  final String answerValue;
  final String snapshotQuestion;
  final String snapshotType;
  final List<String> snapshotOptions;
  final bool snapshotRequired;
  final int snapshotOrder;
}

/// Result of `POST /client/checkin/submit` (201).
class CheckInSubmitResult {
  const CheckInSubmitResult({required this.submissionId, this.submittedAt});

  final String submissionId;
  final DateTime? submittedAt;
}
