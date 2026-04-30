import 'package:athletica/features/info/domain/entities/info_question.dart';

class IntakeQuestionModel extends InfoQuestion {
  const IntakeQuestionModel({
    required super.key,
    required super.prompt,
    required super.type,
    super.options,
    super.required,
    super.sectionKey,
    super.sectionTitle,
  });

  factory IntakeQuestionModel.fromJson(Map<String, dynamic> json) {
    return IntakeQuestionModel(
      key: json['key'] as String,
      prompt: json['prompt'] as String,
      type: _parseType(json['type'] as String),
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      required: json['required'] as bool? ?? true,
      sectionKey: json['sectionKey'] as String?,
      sectionTitle: json['sectionTitle'] as String?,
    );
  }

  static InfoQuestionType _parseType(String type) => switch (type) {
        'select' => InfoQuestionType.select,
        'multiselect' => InfoQuestionType.multiselect,
        'number' => InfoQuestionType.number,
        'textarea' => InfoQuestionType.textarea,
        _ => InfoQuestionType.select,
      };
}
