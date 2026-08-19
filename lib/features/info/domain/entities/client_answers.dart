class ClientAnswer {
  const ClientAnswer({
    required this.questionId,
    required this.answerIndex,
    this.question = '',
    this.value = '',
  });

  final String questionId;
  final int answerIndex;
  final String question;
  final String value;
}

class ClientAnswers {
  const ClientAnswers({required this.answers});

  final List<ClientAnswer> answers;

  bool get isEmpty => answers.isEmpty;
}
