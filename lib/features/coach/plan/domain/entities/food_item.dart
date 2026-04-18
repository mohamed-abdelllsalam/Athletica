class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.emoji,
  });

  final String id;
  final String name;
  final String emoji;
}

abstract class FoodItemsData {
  static const List<FoodItem> all = [
    FoodItem(id: 'f1', name: 'Chicken Breast', emoji: '🍗'),
    FoodItem(id: 'f2', name: 'Chicken Thigh', emoji: '🍖'),
    FoodItem(id: 'f3', name: 'Beef Steak', emoji: '🥩'),
    FoodItem(id: 'f4', name: 'Minced Meat', emoji: '🥩'),
    FoodItem(id: 'f5', name: 'Salmon', emoji: '🐟'),
    FoodItem(id: 'f6', name: 'Tuna', emoji: '🐠'),
    FoodItem(id: 'f7', name: 'Eggs', emoji: '🥚'),
    FoodItem(id: 'f8', name: 'Rice', emoji: '🍚'),
    FoodItem(id: 'f9', name: 'Oats', emoji: '🌾'),
    FoodItem(id: 'f10', name: 'Sweet Potato', emoji: '🍠'),
    FoodItem(id: 'f11', name: 'Broccoli', emoji: '🥦'),
    FoodItem(id: 'f12', name: 'Greek Yogurt', emoji: '🥛'),
  ];
}
