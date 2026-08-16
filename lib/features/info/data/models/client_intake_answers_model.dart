import 'package:athletica/features/info/domain/entities/intake_answer.dart';

class IntakeAnswerModel extends IntakeAnswer {
  const IntakeAnswerModel({
    required super.question,
    required super.value,
  });

  factory IntakeAnswerModel.fromJson(Map<String, dynamic> json) {
    return IntakeAnswerModel(
      question: json['prompt'] as String? ?? '',
      value: json['answer']?.toString() ?? '',
    );
  }
}

class ClientIntakeAnswersModel extends ClientIntakeAnswers {
  const ClientIntakeAnswersModel({
    required super.clientId,
    required super.answers,
    super.completedAt,
  });

  factory ClientIntakeAnswersModel.fromJson(Map<String, dynamic> json) {
    return ClientIntakeAnswersModel(
      clientId: json['clientId'] as String? ?? '',
      answers: json['questionAnswers'] != null
          ? (json['questionAnswers'] as List<dynamic>)
              .map((a) => IntakeAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}
