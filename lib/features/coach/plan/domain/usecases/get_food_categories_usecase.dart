import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';

class GetFoodCategoriesUseCase {
  const GetFoodCategoriesUseCase(this._repository);

  final FoodsRepository _repository;

  Future<ApiResult<List<FoodCategory>>> call() =>
      _repository.getFoodCategories();
}
