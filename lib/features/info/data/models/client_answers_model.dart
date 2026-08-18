import 'package:athletica/features/info/domain/entities/client_answers.dart';

class ClientAnswerModel extends ClientAnswer {
  const ClientAnswerModel({
    required super.questionId,
    required super.answerIndex,
    super.question,
    super.value,
  });

  factory ClientAnswerModel.fromJson(Map<String, dynamic> json) {
    final questionId = json['question_id'] as String? ?? '';
    final rawAnswer = json['answer'];
    final answerIndex = rawAnswer is int
        ? rawAnswer
        : int.tryParse(rawAnswer?.toString() ?? '') ?? -1;
    return ClientAnswerModel(
      questionId: questionId,
      answerIndex: answerIndex,
      question: json['question'] as String? ?? questionId,
      value:
          json['value'] as String? ??
          (answerIndex >= 0 ? '$answerIndex' : rawAnswer?.toString() ?? ''),
    );
  }
}

class ClientAnswersModel extends ClientAnswers {
  const ClientAnswersModel({required super.answers});

  factory ClientAnswersModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? const [];
    return ClientAnswersModel(
      answers: rawAnswers
          .map((a) => ClientAnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
