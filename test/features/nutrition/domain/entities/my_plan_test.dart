import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
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
  MyPlanMeal meal(int order) => MyPlanMeal(
    id: 'meal-$order',
    mealType: 'Meal',
    mealOrder: order,
    foods: const [food],
  );

  group('MyPlan', () {
    test('sums server-scaled food totals across meals', () {
      final plan = MyPlan(id: 'plan', title: 'Plan', meals: [meal(1), meal(2)]);
      expect(plan.totalCalories, 650);
      expect(plan.totalProtein, 14);
      expect(plan.totalCarbs, 140);
      expect(plan.totalFat, 2);
    });

    test('sorts by meal order without changing the original list', () {
      final plan = MyPlan(id: 'plan', title: 'Plan', meals: [meal(2), meal(1)]);
      expect(plan.sortedMeals.map((meal) => meal.mealOrder), [1, 2]);
      expect(plan.meals.map((meal) => meal.mealOrder), [2, 1]);
    });

    test('summary with missing meal details is incomplete', () {
      const plan = MyPlan(id: 'plan', title: 'Plan', mealCount: 2);
      expect(plan.hasCompleteMealData, isFalse);
    });

    test('partially loaded meal details are incomplete', () {
      final plan = MyPlan(
        id: 'plan',
        title: 'Plan',
        mealCount: 2,
        meals: [meal(1)],
      );
      expect(plan.hasCompleteMealData, isFalse);
    });

    test('all reported meal details are complete', () {
      final plan = MyPlan(
        id: 'plan',
        title: 'Plan',
        mealCount: 2,
        meals: [meal(1), meal(2)],
      );
      expect(plan.hasCompleteMealData, isTrue);
    });
  });
}
