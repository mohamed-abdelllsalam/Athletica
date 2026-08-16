class NutritionTemplateItem {
  const NutritionTemplateItem({
    required this.id,
    required this.dayId,
    required this.foodId,
    required this.grams,
  });

  final String id;
  final String dayId;
  final String foodId;
  final int grams;
}
