/// Answer payload keyed by question id, as sent to the backend.
/// Values follow the contract: int choice index for choice questions,
/// non-empty String for text questions.
typedef ClientAnswerPayload = Map<String, Object>;

/// A single stored client answer.
///
/// [answer] is an `int` (choice index) for choice questions and a
/// `String` for text questions, mirroring the backend contract.
class ClientAnswer {
  const ClientAnswer({
    required this.questionId,
    required this.answer,
    this.question = '',
  });

  final String questionId;

  /// Either an int choice index or a String free-text value.
  final Object answer;
  final String question;

  bool get isTextAnswer => answer is String;

  /// Choice index when this is a choice answer; null otherwise.
  int? get choiceIndex => answer is int ? answer as int : null;

  /// Raw text when this is a text answer; empty string otherwise.
  String get textValue => answer is String ? answer as String : '';

  /// Readable answer value used by read-only views.
  String get value => isTextAnswer ? textValue : '$answer';
}

class ClientAnswers {
  const ClientAnswers({
    required this.answers,
    this.total = 0,
    this.totalQuestions = 0,
  });

  final List<ClientAnswer> answers;

  /// Distinct question groups answered (`total` from `GET /client/answers`).
  /// Falls back to `answers.length` for pre-DOC_7 payloads without totals.
  final int total;

  /// Per-language question total (`total_questions`).
  final int totalQuestions;

  bool get isEmpty => answers.isEmpty;

  /// Backend totals are the source of truth for completion. Never use
  /// `answers.length`: bilingual en+ar double answers can make the array
  /// longer than the distinct-group total.
  bool get isComplete => totalQuestions > 0 && total >= totalQuestions;
}
