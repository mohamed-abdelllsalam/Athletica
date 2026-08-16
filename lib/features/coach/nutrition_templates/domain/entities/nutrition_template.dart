class NutritionTemplate {
  const NutritionTemplate({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarb,
    required this.totalFat,
    required this.isPublic,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String trainerId;
  final String title;
  final String description;
  final int totalCalories;
  final int totalProtein;
  final int totalCarb;
  final int totalFat;
  final bool isPublic;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}
