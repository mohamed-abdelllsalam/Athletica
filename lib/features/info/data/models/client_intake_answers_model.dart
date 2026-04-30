import 'package:athletica/features/info/domain/entities/intake_answer.dart';

class IntakeAnswerModel extends IntakeAnswer {
  const IntakeAnswerModel({
    required super.id,
    required super.intakeId,
    required super.question,
    required super.value,
    required super.createdAt,
  });

  factory IntakeAnswerModel.fromJson(Map<String, dynamic> json) {
    return IntakeAnswerModel(
      id: json['id'] as String,
      intakeId: json['intakeId'] as String,
      question: json['question'] as String,
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ClientIntakeAnswersModel extends ClientIntakeAnswers {
  const ClientIntakeAnswersModel({
    required super.clientId,
    required super.answers,
    required super.completedAt,
  });

  factory ClientIntakeAnswersModel.fromJson(Map<String, dynamic> json) {
    return ClientIntakeAnswersModel(
      clientId: json['clientId'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((a) => IntakeAnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
