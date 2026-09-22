/// Lightweight view-model for a template shown in the assign sheet,
/// used for both workout and nutrition templates.
class TemplateItem {
  const TemplateItem({
    required this.id,
    required this.name,
    this.subtitle,
    this.mealCount,
  });

  final String id;
  final String name;
  final String? subtitle;
  final int? mealCount;
}
