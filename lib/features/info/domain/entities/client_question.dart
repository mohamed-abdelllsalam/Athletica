class ClientQuestion {
  const ClientQuestion({
    required this.id,
    required this.groupKey,
    required this.question,
    required this.choices,
    this.language,
    this.createdAt,
  });

  final String id;
  final String groupKey;
  final String question;
  final List<String> choices;
  final String? language;
  final DateTime? createdAt;
}
