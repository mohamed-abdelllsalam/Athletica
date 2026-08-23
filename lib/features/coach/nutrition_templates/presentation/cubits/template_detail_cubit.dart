import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_template_detail_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/reorder_template_meals_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/update_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/update_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_template_ui_mapper.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TemplateDetailState {}

final class TemplateDetailInitial extends TemplateDetailState {}

final class TemplateDetailLoading extends TemplateDetailState {}

final class TemplateDetailLoaded extends TemplateDetailState {
  TemplateDetailLoaded({required this.plan, this.message});

  final NutritionPlan plan;

  /// Transient feedback for a failed mutation; the last known good data
  /// is kept so the screen is not wiped. The UI surfaces [message] and
  /// clears it via [clearMessage].
  final String? message;

  TemplateDetailLoaded copyWith({String? message}) =>
      TemplateDetailLoaded(plan: plan, message: message ?? this.message);
}

final class TemplateDetailError extends TemplateDetailState {
  TemplateDetailError(this.message);

  final String message;
}

class TemplateDetailCubit extends Cubit<TemplateDetailState> {
  TemplateDetailCubit(
    this._getDetail,
    this._addMeal,
    this._updateMeal,
    this._reorderMeals,
    this._addFood,
    this._updateFood,
    this._deleteFood,
    this._deleteMeal,
  ) : super(TemplateDetailInitial());

  final GetNutritionTemplateDetailUseCase _getDetail;
  final AddTemplateMealUseCase _addMeal;
  final UpdateTemplateMealUseCase _updateMeal;
  final ReorderTemplateMealsUseCase _reorderMeals;
  final AddTemplateFoodUseCase _addFood;
  final UpdateTemplateFoodUseCase _updateFood;
  final DeleteTemplateFoodUseCase _deleteFood;
  final DeleteTemplateMealUseCase _deleteMeal;

  static const _mapper = NutritionTemplateUiMapper();

  String get _templateId => switch (state) {
        TemplateDetailLoaded(:final plan) => plan.id,
        _ => '',
      };

  Future<void> load(String templateId) async {
    emit(TemplateDetailLoading());

    final result = await _getDetail(templateId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(TemplateDetailLoaded(plan: _mapper.toPlan(data)));
      case ApiError(:final failure):
        emit(TemplateDetailError(failure.message));
    }
  }

  Future<void> refresh() async {
    if (_templateId.isEmpty) return;
    final result = await _getDetail(_templateId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(TemplateDetailLoaded(plan: _mapper.toPlan(data)));
      case ApiError(:final failure):
        emit(TemplateDetailLoaded(
          plan: (state as TemplateDetailLoaded).plan,
          message: failure.message,
        ));
    }
  }

  void clearMessage() {
    final state = this.state;
    if (state is TemplateDetailLoaded && state.message != null) {
      emit(TemplateDetailLoaded(plan: state.plan));
    }
  }

  /// Adds a meal to the persisted template (view mode "+ Add Meal").
  Future<void> addMeal() async {
    final state = this.state;
    if (state is! TemplateDetailLoaded) return;
    final mealType = 'Meal ${state.plan.meals.length + 1}';

    final result = await _addMeal(_templateId, mealType: mealType);
    switch (result) {
      case ApiSuccess():
        await refresh();
      case ApiError(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  /// Reorders meals after a drag & drop. Applies the move optimistically,
  /// then pushes the full permutation (orders 1..N) to the backend
  /// (`PUT /nutrition/templates/:id/meals/reorder`).
  Future<void> reorderMeals(int oldIndex, int newIndex) async {
    final current = state;
    if (current is! TemplateDetailLoaded) return;

    var meals = List<Meal>.from(current.plan.meals);
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 ||
        oldIndex >= meals.length ||
        newIndex < 0 ||
        newIndex >= meals.length) {
      return;
    }
    final moved = meals.removeAt(oldIndex);
    meals.insert(newIndex, moved);

    // Optimistic UI update so the list reflects the drag immediately.
    emit(
      TemplateDetailLoaded(
        plan: NutritionPlan(
          id: current.plan.id,
          name: current.plan.name,
          category: current.plan.category,
          calories: current.plan.calories,
          proteinGrams: current.plan.proteinGrams,
          fatGrams: current.plan.fatGrams,
          carbsGrams: current.plan.carbsGrams,
          planDuration: current.plan.planDuration,
          updatedAgo: current.plan.updatedAgo,
          clientCount: current.plan.clientCount,
          meals: meals,
          description: current.plan.description,
          iconAsset: current.plan.iconAsset,
        ),
      ),
    );

    final orders = <({String mealId, int mealOrder})>[
      for (var i = 0; i < meals.length; i++)
        (mealId: meals[i].id, mealOrder: i + 1),
    ];
    final result = await _reorderMeals(_templateId, orders);
    switch (result) {
      case ApiSuccess():
        // Re-sync with server truth so the UI never shows an order the
        // backend did not actually persist.
        await refresh();
      case ApiError(:final failure):
        // Roll back to server truth and surface the error.
        emit(TemplateDetailLoaded(
          plan: current.plan,
          message: failure.message,
        ));
    }
  }

  /// Deletes a meal from the persisted template (cascades its foods on the
  /// backend), then refreshes so the UI reflects server state.
  Future<void> deleteMeal(String mealId) async {
    final state = this.state;
    if (state is! TemplateDetailLoaded) return;

    final result = await _deleteMeal(_templateId, mealId);
    switch (result) {
      case ApiSuccess():
        await refresh();
      case ApiError(:final failure):
        emit(state.copyWith(message: failure.message));
    }
  }

  /// Persists the differences between the originally loaded meal and the
  /// edited [editedMeal] returned by MealDetailView, then refreshes from
  /// the backend so the UI always reflects server state.
  Future<void> applyMealEdits(Meal editedMeal) async {
    final state = this.state;
    if (state is! TemplateDetailLoaded) return;

    final original = state.plan.meals
        .where((m) => m.id == editedMeal.id)
        .firstOrNull;
    if (original == null) {
      await refresh();
      return;
    }

    // 1. Removed ingredients -> DELETE relation
    final editedRelations =
        editedMeal.ingredients.map((i) => i.relationId).toSet();
    for (final ingredient in original.ingredients) {
      final relationId = ingredient.relationId;
      if (relationId != null && !editedRelations.contains(relationId)) {
        final result =
            await _deleteFood(_templateId, editedMeal.id, relationId);
        switch (result) {
          case ApiError(:final failure):
            emit(state.copyWith(message: failure.message));
            return;
          case ApiSuccess():
            break;
        }
      }
    }

    // 2. Added ingredients (no relation yet, must carry a catalog foodId)
    final originalRelations =
        original.ingredients.map((i) => i.relationId).toSet();
    for (final ingredient in editedMeal.ingredients) {
      if (ingredient.relationId != null ||
          !_isValidUuid(ingredient.foodId)) {
        continue;
      }
      final quantity = ingredient.grams > 0 ? ingredient.grams : 100;
      final result = await _addFood(
        _templateId,
        editedMeal.id,
        foodId: ingredient.foodId!,
        quantity: quantity,
      );
      switch (result) {
        case ApiError(:final failure):
          emit(state.copyWith(message: failure.message));
          return;
        case ApiSuccess():
          break;
      }
      originalRelations.add(ingredient.relationId);
    }

    // 3. Quantity changes on existing relations
    for (final ingredient in editedMeal.ingredients) {
      final relationId = ingredient.relationId;
      if (relationId == null || !originalRelations.contains(relationId)) {
        continue;
      }
      final before = original.ingredients
          .where((i) => i.relationId == relationId)
          .firstOrNull;
      if (before == null || before.grams == ingredient.grams) continue;
      final result = await _updateFood(
        _templateId,
        editedMeal.id,
        relationId,
        quantity: ingredient.grams,
      );
      switch (result) {
        case ApiError(:final failure):
          emit(state.copyWith(message: failure.message));
          return;
        case ApiSuccess():
          break;
      }
    }

    // 4. Name (meal_type) and notes changes
    final newName = editedMeal.name.trim();
    final nameChanged =
        newName.isNotEmpty && newName != original.name.trim();
    final notesChanged = (editedMeal.notes ?? '') != (original.notes ?? '');
    if (nameChanged || notesChanged) {
      final result = await _updateMeal(
        _templateId,
        editedMeal.id,
        mealType: nameChanged ? newName : null,
        notes: notesChanged ? (editedMeal.notes ?? '') : null,
      );
      switch (result) {
        case ApiError(:final failure):
          emit(state.copyWith(message: failure.message));
          return;
        case ApiSuccess():
          break;
      }
    }

    await refresh();
  }

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool _isValidUuid(String? id) =>
      id != null && _uuidRegex.hasMatch(id);
}
