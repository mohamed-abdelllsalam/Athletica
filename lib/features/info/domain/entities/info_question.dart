enum InfoQuestionType { select, multiselect, number, textarea }

class InfoQuestion {
  const InfoQuestion({
    required this.key,
    required this.prompt,
    this.type = InfoQuestionType.select,
    this.options,
    this.required = true,
    this.sectionKey,
    this.sectionTitle,
  });

  final String key;
  final String prompt;
  final InfoQuestionType type;
  final List<String>? options;
  final bool required;
  final String? sectionKey;
  final String? sectionTitle;
}