import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/create_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Persists a plan built in the create-mode editor:
/// 1. POST /nutrition/templates            (title + description)
/// 2. POST /nutrition/templates/:id/meals  (one call per meal, in order)
/// 3. POST /nutrition/templates/:id/meals/:mealId/foods (per ingredient)
class SaveNutritionPlanCubit extends Cubit<SaveNutritionPlanState> {
  SaveNutritionPlanCubit(
    this._createTemplate,
    this._addMeal,
    this._addFood,
  ) : super(SaveNutritionPlanIdle());

  final CreateNutritionTemplateUseCase _createTemplate;
  final AddTemplateMealUseCase _addMeal;
  final AddTemplateFoodUseCase _addFood;

  Future<void> savePlan(NutritionPlan plan) async {
    if (state is SaveNutritionPlanLoading) return;
    emit(SaveNutritionPlanLoading());

    // 1. Create the template
    final templateResult = await _createTemplate(
      title: plan.name,
      description: plan.description,
    );

    final String templateId;
    switch (templateResult) {
      case ApiSuccess(:final data):
        templateId = data.id;
      case ApiError(:final failure):
        if (isClosed) return;
        emit(SaveNutritionPlanError(failure.message));
        return;
    }

    // 2. Create each meal in order
    for (int i = 0; i < plan.meals.length; i++) {
      final meal = plan.meals[i];

      final mealResult = await _addMeal(
        templateId,
        // The required coach-entered name is persisted as backend meal_type.
        mealType: meal.name,
        mealOrder: i + 1,
        notes: meal.notes,
      );

      final String mealId;
      switch (mealResult) {
        case ApiSuccess(:final data):
          mealId = data.id;
        case ApiError(:final failure):
          if (isClosed) return;
          emit(SaveNutritionPlanError(_partialMessage(failure.message)));
          return;
      }

      // 3. Add foods to this meal — only ingredients backed by a real
      //    catalog food UUID can be persisted.
      for (final ingredient in meal.ingredients) {
        if (!_isValidUuid(ingredient.foodId)) continue;
        final quantity = ingredient.grams > 0 ? ingredient.grams : 100;
        final foodResult = await _addFood(
          templateId,
          mealId,
          foodId: ingredient.foodId!,
          quantity: quantity,
        );
        switch (foodResult) {
          case ApiError(:final failure):
            if (isClosed) return;
            emit(SaveNutritionPlanError(_partialMessage(failure.message)));
            return;
          case ApiSuccess():
            break;
        }
      }
    }

    if (isClosed) return;
    emit(SaveNutritionPlanSuccess());
  }

  /// The template (and any earlier meals/foods) already exists server-side
  /// when a meal/food write fails — there is no transactional endpoint —
  /// so the message must say so instead of implying nothing was saved.
  /// Retrying creates a new template; the coach should check the library
  /// first to avoid duplicates.
  static String _partialMessage(String serverMessage) =>
      '$serverMessage The plan was partially saved — check your library before trying again.';

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  bool _isValidUuid(String? id) =>
      id != null && _uuidRegex.hasMatch(id);
}
