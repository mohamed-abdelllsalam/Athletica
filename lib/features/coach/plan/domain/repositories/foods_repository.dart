import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';

typedef FoodsPageResult = ApiResult<({List<FoodItem> foods, ApiPagination pagination})>;

abstract class FoodsRepository {
  Future<FoodsPageResult> getFoods({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  });

  Future<ApiResult<List<FoodCategory>>> getFoodCategories();
}
