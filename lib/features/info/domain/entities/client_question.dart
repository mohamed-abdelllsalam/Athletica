enum QuestionType {
  choice,
  text;

  /// Maps the API's `question_type` string to a [QuestionType].
  ///
  /// Unknown or missing values fall back to [choice] so legacy payloads
  /// without `question_type` keep rendering as choice questions.
  static QuestionType fromApi(Object? value) =>
      QuestionType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => QuestionType.choice,
      );
}

class ClientQuestion {
  const ClientQuestion({
    required this.id,
    required this.groupKey,
    required this.question,
    required this.choices,
    this.questionType = QuestionType.choice,
    this.language,
    this.createdAt,
  });

  final String id;
  final String groupKey;
  final String question;
  final List<String> choices;
  final QuestionType questionType;
  final String? language;
  final DateTime? createdAt;

  bool get isTextQuestion => questionType == QuestionType.text;
}
