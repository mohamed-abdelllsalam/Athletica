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
  const ClientAnswers({required this.answers});

  final List<ClientAnswer> answers;

  bool get isEmpty => answers.isEmpty;
}
