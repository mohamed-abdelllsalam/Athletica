class NutritionPlan {
  const NutritionPlan({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.planDuration,
    required this.updatedAgo,
    required this.clientCount,
    required this.meals,
    required this.description,
    required this.iconAsset,
  });

  final String id;
  final String name;
  final String category;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final String planDuration;
  final String updatedAgo;
  final int clientCount;
  final List<Meal> meals;
  final String description;
  final String iconAsset;
}

class Meal {
  Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.ingredients,
  });

  final String id;
  final String type;
  final String name;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  List<Ingredient> ingredients;
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.serving,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final String id;
  final String name;
  final String emoji;
  final String serving;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
}

abstract class NutritionPlansData {
  static List<NutritionPlan> get plans => [
        NutritionPlan(
          id: 'np1',
          name: 'Fat loss Nutrition plan',
          category: 'Fat loss',
          calories: 1800,
          proteinGrams: 150,
          fatGrams: 50,
          carbsGrams: 180,
          planDuration: '4 Week Plan',
          updatedAgo: 'Updated 2 days ago',
          clientCount: 7,
          iconAsset: 'assets/images/plan/fatloss_icon.svg',
          description:
              'A balanced nutrition plan designed for loss\nwhile maintaining muscle and energy',
          meals: [
            Meal(
              id: 'm1',
              type: 'Breakfast',
              name: 'Oatmeal with Fruits',
              calories: 450,
              proteinGrams: 35,
              fatGrams: 10,
              carbsGrams: 60,
              ingredients: [
                const Ingredient(
                  id: 'i1',
                  name: 'Oats',
                  emoji: '🌾',
                  serving: '1 cup (80)',
                  calories: 300,
                  proteinGrams: 10,
                  carbsGrams: 54,
                  fatGrams: 6,
                ),
                const Ingredient(
                  id: 'i2',
                  name: 'Banana',
                  emoji: '🍌',
                  serving: '1 Medium (120)',
                  calories: 105,
                  proteinGrams: 1,
                  carbsGrams: 27,
                  fatGrams: 0,
                ),
                const Ingredient(
                  id: 'i3',
                  name: 'Blueberries',
                  emoji: '🫐',
                  serving: '1/2 cup (75)',
                  calories: 40,
                  proteinGrams: 10,
                  carbsGrams: 10,
                  fatGrams: 0,
                ),
                const Ingredient(
                  id: 'i4',
                  name: 'Honey',
                  emoji: '🍯',
                  serving: '1 tbsp (80)',
                  calories: 45,
                  proteinGrams: 0,
                  carbsGrams: 12,
                  fatGrams: 0,
                ),
                const Ingredient(
                  id: 'i5',
                  name: 'Almonds',
                  emoji: '🌰',
                  serving: '10 pieces (15)',
                  calories: 60,
                  proteinGrams: 2,
                  carbsGrams: 2,
                  fatGrams: 5,
                ),
              ],
            ),
            Meal(
              id: 'm2',
              type: 'Lunch',
              name: 'Grilled Chicken & Rice',
              calories: 500,
              proteinGrams: 40,
              fatGrams: 10,
              carbsGrams: 55,
              ingredients: [],
            ),
            Meal(
              id: 'm3',
              type: 'Snack',
              name: 'Greek Yogurt & Nuts',
              calories: 250,
              proteinGrams: 20,
              fatGrams: 8,
              carbsGrams: 20,
              ingredients: [],
            ),
            Meal(
              id: 'm4',
              type: 'Dinner',
              name: 'Salmon with Vegetables',
              calories: 500,
              proteinGrams: 40,
              fatGrams: 20,
              carbsGrams: 15,
              ingredients: [],
            ),
            Meal(
              id: 'm5',
              type: 'Snack 2',
              name: 'Protein Shake & Banana',
              calories: 100,
              proteinGrams: 15,
              fatGrams: 2,
              carbsGrams: 30,
              ingredients: [],
            ),
          ],
        ),
        NutritionPlan(
          id: 'np2',
          name: 'Muscle Gain Meal Plan',
          category: 'Fat loss',
          calories: 2800,
          proteinGrams: 200,
          fatGrams: 80,
          carbsGrams: 300,
          planDuration: '6 Week Plan',
          updatedAgo: 'Updated 5 days ago',
          clientCount: 5,
          iconAsset: 'assets/images/plan/muscle_gain_icon.svg',
          description:
              'A muscle gain nutrition plan\nfor building lean mass',
          meals: [],
        ),
        NutritionPlan(
          id: 'np3',
          name: 'Muscle Gain Meal Plan',
          category: 'Fat loss',
          calories: 2500,
          proteinGrams: 180,
          fatGrams: 70,
          carbsGrams: 250,
          planDuration: '4 Week Plan',
          updatedAgo: 'Updated 1 week ago',
          clientCount: 3,
          iconAsset: 'assets/images/plan/muscle_gain_icon.svg',
          description:
              'Another muscle gain plan\nfor intermediate lifters',
          meals: [],
        ),
        NutritionPlan(
          id: 'np4',
          name: 'Vegan Nutrition plan',
          category: 'Vegan',
          calories: 1600,
          proteinGrams: 100,
          fatGrams: 40,
          carbsGrams: 200,
          planDuration: '6 Week Plan',
          updatedAgo: 'Updated 5 days ago',
          clientCount: 5,
          iconAsset: 'assets/images/plan/vegan_icon.svg',
          description:
              'A plant-based nutrition plan\nfor vegans and vegetarians',
          meals: [],
        ),
        NutritionPlan(
          id: 'np5',
          name: 'Intermittent Fasting Plan',
          category: 'Custom',
          calories: 1400,
          proteinGrams: 120,
          fatGrams: 50,
          carbsGrams: 100,
          planDuration: '3 Week Plan',
          updatedAgo: 'Updated 6 days ago',
          clientCount: 8,
          iconAsset: 'assets/images/plan/intermittent_icon.svg',
          description:
              'An intermittent fasting nutrition plan\nfor weight management',
          meals: [],
        ),
        NutritionPlan(
          id: 'np6',
          name: 'High Protein Meal Plan',
          category: 'Custom',
          calories: 2200,
          proteinGrams: 220,
          fatGrams: 60,
          carbsGrams: 180,
          planDuration: '5 Week Plan',
          updatedAgo: 'Updated 6 days ago',
          clientCount: 12,
          iconAsset: 'assets/images/plan/high_protein.svg',
          description:
              'A high protein nutrition plan\nfor athletes',
          meals: [],
        ),
      ];
}
