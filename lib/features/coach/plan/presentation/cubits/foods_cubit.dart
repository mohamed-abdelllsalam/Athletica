import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_food_categories_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_foods_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class FoodsState {}

final class FoodsInitial extends FoodsState {}

final class FoodsLoading extends FoodsState {}

final class FoodsLoaded extends FoodsState {
  FoodsLoaded({required this.foods, required this.categories});

  final List<FoodItem> foods;
  final List<FoodCategory> categories;
}

final class FoodsError extends FoodsState {
  FoodsError(this.message);

  final String message;
}

class FoodsCubit extends Cubit<FoodsState> {
  FoodsCubit(this._getFoods, this._getCategories) : super(FoodsInitial());

  final GetFoodsUseCase _getFoods;
  final GetFoodCategoriesUseCase _getCategories;

  Future<void> load() async {
    emit(FoodsLoading());

    final foodsResult = await _getFoods();
    final categoriesResult = await _getCategories();

    switch (foodsResult) {
      case ApiError(:final failure):
        emit(FoodsError(failure.message));
        return;
      case ApiSuccess():
    }

    switch (categoriesResult) {
      case ApiError(:final failure):
        emit(FoodsError(failure.message));
        return;
      case ApiSuccess():
    }

    emit(FoodsLoaded(
      foods: foodsResult.data,
      categories: categoriesResult.data,
    ));
  }
}
