/// One day of meal-completion history from `GET /nutrition/history`.
class NutritionHistoryDay {
  const NutritionHistoryDay({
    required this.date,
    required this.totalMeals,
    required this.completedMeals,
    required this.allCompleted,
  });

  /// Date in `YYYY-MM-DD` format as returned by the API.
  final String date;
  final int totalMeals;
  final int completedMeals;
  final bool allCompleted;
}
