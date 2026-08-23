/// A food entry inside a plan meal, with macros already scaled to the
/// quantity by the backend.
class MealFood {
  const MealFood({
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String foodId;
  final String name;
  final num quantity;
  final String servingUnit;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
}
