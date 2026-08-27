import 'package:athletica/features/info/domain/entities/client_question.dart';

class ClientQuestionModel extends ClientQuestion {
  const ClientQuestionModel({
    required super.id,
    required super.groupKey,
    required super.question,
    required super.choices,
    super.questionType,
    super.language,
    super.createdAt,
    super.questionEn,
    super.questionAr,
    super.choicesEn,
    super.choicesAr,
    super.arabicId,
  });

  factory ClientQuestionModel.fromJson(Map<String, dynamic> json) {
    return ClientQuestionModel(
      id: json['id'] as String,
      groupKey: json['group_key'] as String? ?? '',
      question: json['question'] as String,
      choices: (json['choices'] as List<dynamic>? ?? const []).cast<String>(),
      questionType: QuestionType.fromApi(json['question_type']),
      language: json['language'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
