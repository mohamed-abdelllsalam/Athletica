import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const food = MealFood(
    foodId: 'food',
    name: 'Rice',
    quantity: 250,
    servingUnit: 'g',
    calories: 325,
    protein: 7,
    carbs: 70,
    fat: 1,
  );
  TodayMeal meal(int order, {bool completed = false}) => TodayMeal(
    mealLogId: 'log-$order',
    mealId: 'meal-$order',
    mealType: 'Meal',
    mealOrder: order,
    completed: completed,
    foods: const [food],
  );

  group('TodayMeals', () {
    test('sums server-scaled nutrients without multiplying by quantity', () {
      final meals = TodayMeals(meals: [meal(1), meal(2)], dayCompleted: false);
      expect(meals.totalCalories, 650);
      expect(meals.totalProtein, 14);
      expect(meals.totalCarbs, 140);
      expect(meals.totalFat, 2);
    });

    test('weights macro energy with four and nine calories per gram', () {
      final meals = TodayMeals(meals: [meal(1)], dayCompleted: false);
      expect(meals.caloriesFromCarbs, 280);
      expect(meals.caloriesFromProtein, 28);
      expect(meals.caloriesFromFat, 9);
      expect(meals.totalMacroCalories, 317);
    });

    test('empty meals have zero totals and zero completion progress', () {
      expect(TodayMeals.empty.totalCalories, 0);
      expect(TodayMeals.empty.totalMacroCalories, 0);
      expect(TodayMeals.empty.completedMealCount, 0);
      expect(TodayMeals.empty.completionProgress, 0);
    });

    test('sorts meals by order without changing the original list', () {
      final meals = TodayMeals(
        meals: [meal(3), meal(1), meal(2)],
        dayCompleted: false,
      );
      expect(meals.sortedMeals.map((meal) => meal.mealOrder), [1, 2, 3]);
      expect(meals.meals.map((meal) => meal.mealOrder), [3, 1, 2]);
    });

    test('calculates progress from individual completed meals', () {
      final meals = TodayMeals(
        meals: [meal(1, completed: true), meal(2)],
        dayCompleted: false,
      );
      expect(meals.completedMealCount, 1);
      expect(meals.completionProgress, 0.5);
    });
  });
}
