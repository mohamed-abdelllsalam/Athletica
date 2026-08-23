import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';

/// Maps backend nutrition template entities onto the UI-facing
/// [NutritionPlan] bridge entity consumed by the approved screens.
class NutritionTemplateUiMapper {
  const NutritionTemplateUiMapper();

  NutritionPlan toPlan(NutritionTemplate t) => NutritionPlan(
        id: t.id,
        name: t.title,
        category: 'Custom',
        calories: t.totalCalories,
        proteinGrams: t.totalProtein,
        fatGrams: t.totalFat,
        carbsGrams: t.totalCarbs,
        planDuration: '—',
        updatedAgo: timeAgo(t.createdAt),
        clientCount: 0,
        meals: t.meals.map(toMeal).toList(),
        description: t.description,
        iconAsset: 'assets/images/plan/nutrition_icon.svg',
      );

  Meal toMeal(NutritionTemplateMeal m) {
    final label = capitalize(m.mealType);
    return Meal(
      id: m.id,
      type: label,
      // The backend has no separate meal-name field; the label doubles as
      // the local session name (see contract report).
      name: label,
      calories: m.totalCalories,
      proteinGrams: m.totalProtein,
      fatGrams: m.totalFat,
      carbsGrams: m.totalCarbs,
      ingredients: m.foods.map(toIngredient).toList(),
      order: m.mealOrder,
      notes: m.notes,
    );
  }

  Ingredient toIngredient(NutritionTemplateMealFood f) {
    final grams = f.quantity;
    final display =
        grams == grams.roundToDouble() ? grams.toInt().toString() : grams.toString();
    return Ingredient(
      id: f.id,
      foodId: f.foodId,
      relationId: f.id,
      name: f.foodName,
      emoji: '🍽️',
      serving: '${display}g',
      calories: f.calories.round(),
      proteinGrams: f.protein.round(),
      carbsGrams: f.carbs.round(),
      fatGrams: f.fat.round(),
    );
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
