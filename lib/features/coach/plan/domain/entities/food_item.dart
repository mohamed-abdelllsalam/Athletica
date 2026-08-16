class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.categoryId,
    required this.serving,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final String id;
  final String name;
  final String emoji;
  final String category;
  final String categoryId;
  final String serving;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
}
