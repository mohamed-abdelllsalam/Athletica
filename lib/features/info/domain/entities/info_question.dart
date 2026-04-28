enum InfoQuestionType { text, dropdown, multiselect, textarea }

class InfoQuestion {
  const InfoQuestion({
    required this.key,
    required this.question,
    this.type = InfoQuestionType.dropdown,
    this.options,
  });

  final String key;
  final String question;
  final InfoQuestionType type;
  final List<String>? options;
}
