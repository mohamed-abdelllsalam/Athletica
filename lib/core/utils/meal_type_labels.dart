/// Display labels for backend meal types, shared across client nutrition
/// screens.
const Map<String, String> mealTypeLabels = {
  'breakfast': 'Breakfast',
  'lunch': 'Lunch',
  'dinner': 'Dinner',
  'snacks': 'Snacks',
  'snack': 'Snacks',
};

/// Stable display order rank for common meal types; unknown types go last.
const Map<String, String> mealTypeOrder = {
  'breakfast': '0',
  'lunch': '1',
  'snack': '2',
  'snacks': '2',
  'dinner': '3',
};

String labelForMealType(String raw) {
  final label = mealTypeLabels[raw];
  if (label != null) return label;
  if (raw.isEmpty) return raw;
  return raw[0].toUpperCase() + raw.substring(1);
}
