import 'package:athletica/features/info/domain/entities/client_answers.dart';

class ClientAnswerModel extends ClientAnswer {
  const ClientAnswerModel({
    required super.questionId,
    required super.answer,
    super.question,
  });

  /// Parses an answer while preserving the backend's raw value shape:
  /// choice answers may arrive as `0` or `"0"`, text answers as strings.
  ///
  /// Type resolution (index vs text) happens where the matching question
  /// type is known — the parsing layer must not guess and drop information.
  factory ClientAnswerModel.fromJson(Map<String, dynamic> json) {
    final questionId = json['question_id'] as String? ?? '';
    final question = json['question'] as String? ?? questionId;
    return ClientAnswerModel(
      questionId: questionId,
      answer: _parseRawAnswer(json['answer']),
      question: question,
    );
  }

  static Object _parseRawAnswer(Object? raw) {
    if (raw == null) return '';
    if (raw is num) {
      final asInt = raw.toInt();
      // Preserve integers exactly (choice indexes); keep others as text.
      return asInt == raw ? asInt : raw.toString();
    }
    if (raw is bool) return raw.toString();
    return raw.toString();
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
