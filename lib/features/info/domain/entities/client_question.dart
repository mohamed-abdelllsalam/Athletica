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
    this.questionEn,
    this.questionAr,
    this.choicesEn,
    this.choicesAr,
    this.arabicId,
  });

  /// Primary identifier — English record ID, used for answer submission.
  final String id;
  final String groupKey;
  final String question;
  final List<String> choices;
  final QuestionType questionType;
  final String? language;
  final DateTime? createdAt;
  final String? questionEn;
  final String? questionAr;
  final List<String>? choicesEn;
  final List<String>? choicesAr;

  /// Arabic record ID — used to match saved answers that reference
  /// the Arabic question instead of the English one.
  final String? arabicId;

  bool get isTextQuestion => questionType == QuestionType.text;
}
