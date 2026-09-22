import 'package:athletica/features/check_ins/domain/entities/check_in.dart';

CheckInQuestionType _typeFromJson(dynamic value) =>
    CheckInQuestionType.values.byName(value as String);

String _typeToJson(CheckInQuestionType type) => type.name;

/// Data model for `CheckinQuestion` (CHECK_IN.md §3.1).
///
/// Extends the domain entity; manual `fromJson`/`toJson`, no codegen.
class CheckInQuestionModel extends CheckInQuestion {
  const CheckInQuestionModel({
    required super.id,
    required super.label,
    required super.type,
    super.coachId,
    super.options,
    super.required,
    super.order,
  });

  factory CheckInQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();
    return CheckInQuestionModel(
      id: json['id'] as String,
      label: json['question'] as String,
      type: _typeFromJson(json['type']),
      coachId: json['coach_id'] as String? ?? '',
      options: options,
      required: json['required'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'coach_id': coachId,
        'question': label,
        'type': _typeToJson(type),
        'options': options,
        'required': required,
        'order': order,
      };

  CheckInQuestion toEntity() => CheckInQuestion(
        id: id,
        label: label,
        type: type,
        coachId: coachId,
        options: List.unmodifiable(options),
        required: required,
        order: order,
      );
}
