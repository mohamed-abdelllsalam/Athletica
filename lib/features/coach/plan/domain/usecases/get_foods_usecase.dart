import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';

class GetFoodsUseCase {
  const GetFoodsUseCase(this._repository);

  final FoodsRepository _repository;

  Future<ApiResult<List<FoodItem>>> call({int limit = 100}) =>
      _repository.getFoods(limit: limit);
}
