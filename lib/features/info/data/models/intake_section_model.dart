import 'package:athletica/features/info/data/models/intake_question_model.dart';
import 'package:athletica/features/info/domain/entities/intake_section.dart';

class IntakeSectionModel extends IntakeSection {
  const IntakeSectionModel({
    required super.key,
    required super.title,
    required super.description,
    required super.questions,
  });

  factory IntakeSectionModel.fromJson(Map<String, dynamic> json) {
    return IntakeSectionModel(
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => IntakeQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
