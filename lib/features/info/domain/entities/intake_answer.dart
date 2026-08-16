class IntakeAnswer {
  const IntakeAnswer({
    required this.question,
    required this.value,
  });

  final String question;
  final String value;
}

class ClientIntakeAnswers {
  const ClientIntakeAnswers({
    required this.clientId,
    required this.answers,
    this.completedAt,
  });

  final String clientId;
  final List<IntakeAnswer> answers;
  final DateTime? completedAt;
}
