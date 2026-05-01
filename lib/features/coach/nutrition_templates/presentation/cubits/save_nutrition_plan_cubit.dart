import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/create_nutrition_template_day_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/create_nutrition_template_item_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/create_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveNutritionPlanCubit extends Cubit<SaveNutritionPlanState> {
  SaveNutritionPlanCubit(
    this._createTemplate,
    this._createDay,
    this._createItem,
  ) : super(SaveNutritionPlanIdle());

  final CreateNutritionTemplateUseCase _createTemplate;
  final CreateNutritionTemplateDayUseCase _createDay;
  final CreateNutritionTemplateItemUseCase _createItem;

  Future<void> savePlan(NutritionPlan plan) async {
    if (state is SaveNutritionPlanLoading) return;
    emit(SaveNutritionPlanLoading());

    // 1. Create the template
    final templateResult = await _createTemplate(
      title: plan.name,
      description: plan.description,
      isPublic: false,
      dailyTargetCalories: plan.calories,
      dailyTargetProtein: plan.proteinGrams,
      dailyTargetCarbs: plan.carbsGrams,
      dailyTargetFats: plan.fatGrams,
    );

    final String templateId;
    switch (templateResult) {
      case ApiSuccess(:final data):
        templateId = data.id;
      case ApiError(:final failure):
        emit(SaveNutritionPlanError(failure.message));
        return;
    }

    // 2. Create each meal as a day, then its ingredients as items
    for (int i = 0; i < plan.meals.length; i++) {
      final meal = plan.meals[i];

      final dayResult = await _createDay(
        templateId: templateId,
        name: meal.type,
        dayNumber: i + 1,
      );

      final String dayId;
      switch (dayResult) {
        case ApiSuccess(:final data):
          dayId = data.id;
        case ApiError(:final failure):
          emit(SaveNutritionPlanError(failure.message));
          return;
      }

      // 3. Create food items for this meal — skip non-UUID ingredient ids
      for (final ingredient in meal.ingredients) {
        if (!_isValidUuid(ingredient.id)) continue;
        final grams = _parseGrams(ingredient.serving);
        final itemResult = await _createItem(
          dayId: dayId,
          foodId: ingredient.id,
          grams: grams,
        );
        switch (itemResult) {
          case ApiError(:final failure):
            emit(SaveNutritionPlanError(failure.message));
            return;
          case ApiSuccess():
            break;
        }
      }
    }

    emit(SaveNutritionPlanSuccess());
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  bool _isValidUuid(String id) => _uuidRegex.hasMatch(id);

  int _parseGrams(String serving) {
    // Handles "100g" format (from FoodItem.serving)
    final gMatch = RegExp(r'^(\d+)g$').firstMatch(serving.trim());
    if (gMatch != null) return int.parse(gMatch.group(1)!);
    // Handles "1 cup (80)" format (from mock data)
    final parenMatch = RegExp(r'\((\d+)\)').firstMatch(serving);
    if (parenMatch != null) return int.parse(parenMatch.group(1)!);
    return 100;
  }
}
