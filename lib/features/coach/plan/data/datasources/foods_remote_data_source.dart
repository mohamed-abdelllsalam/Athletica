import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/plan/data/models/food_category_model.dart';
import 'package:athletica/features/coach/plan/data/models/food_item_model.dart';
import 'package:dio/dio.dart';

abstract class FoodsRemoteDataSource {
  Future<List<FoodItemModel>> getFoods({int limit = 100});
  Future<List<FoodCategoryModel>> getFoodCategories();
}

class FoodsRemoteDataSourceImpl implements FoodsRemoteDataSource {
  const FoodsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FoodItemModel>> getFoods({int limit = 100}) async {
    final response = await _dio.get(
      ApiEndpoints.foods,
      queryParameters: {'limit': limit, 'sort': 'name', 'order': 'asc'},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FoodCategoryModel>> getFoodCategories() async {
    final response = await _dio.get(ApiEndpoints.foodCategories);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => FoodCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
