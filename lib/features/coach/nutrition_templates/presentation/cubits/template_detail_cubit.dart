import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_template_detail_usecase.dart';
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
    this._addFood,
    this._updateFood,
    this._deleteFood,
  ) : super(TemplateDetailInitial());

  final GetNutritionTemplateDetailUseCase _getDetail;
  final AddTemplateMealUseCase _addMeal;
  final UpdateTemplateMealUseCase _updateMeal;
  final AddTemplateFoodUseCase _addFood;
  final UpdateTemplateFoodUseCase _updateFood;
  final DeleteTemplateFoodUseCase _deleteFood;

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

    // 4. Notes change
    if ((editedMeal.notes ?? '') != (original.notes ?? '')) {
      final result = await _updateMeal(
        _templateId,
        editedMeal.id,
        notes: editedMeal.notes ?? '',
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
