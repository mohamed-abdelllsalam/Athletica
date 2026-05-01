import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_day.dart';

class NutritionTemplateDayModel {
  const NutritionTemplateDayModel({
    required this.id,
    required this.templateId,
    required this.name,
    required this.dayNumber,
  });

  final String id;
  final String templateId;
  final String name;
  final int dayNumber;

  factory NutritionTemplateDayModel.fromJson(Map<String, dynamic> json) =>
      NutritionTemplateDayModel(
        id: json['id'] as String,
        templateId: (json['templateId'] as String?) ??
            (json['mealTemplateId'] as String?) ??
            '',
        name: (json['name'] as String?) ?? '',
        dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      );

  NutritionTemplateDay toEntity() => NutritionTemplateDay(
        id: id,
        templateId: templateId,
        name: name,
        dayNumber: dayNumber,
      );
}
