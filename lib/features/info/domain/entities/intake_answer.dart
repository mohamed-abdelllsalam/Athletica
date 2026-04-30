class IntakeAnswer {
  const IntakeAnswer({
    required this.id,
    required this.intakeId,
    required this.question,
    required this.value,
    required this.createdAt,
  });

  final String id;
  final String intakeId;
  final String question;
  final String value;
  final DateTime createdAt;
}

class ClientIntakeAnswers {
  const ClientIntakeAnswers({
    required this.clientId,
    required this.answers,
    required this.completedAt,
  });

  final String clientId;
  final List<IntakeAnswer> answers;
  final DateTime completedAt;
}
