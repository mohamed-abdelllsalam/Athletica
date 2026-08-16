import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';

abstract class FoodsRepository {
  Future<ApiResult<List<FoodItem>>> getFoods({int limit = 100});
  Future<ApiResult<List<FoodCategory>>> getFoodCategories();
}
