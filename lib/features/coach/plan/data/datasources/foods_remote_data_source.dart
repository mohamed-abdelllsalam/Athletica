import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/coach/plan/data/models/food_category_model.dart';
import 'package:athletica/features/coach/plan/data/models/food_item_model.dart';
import 'package:dio/dio.dart';

typedef FoodsPage = ({List<FoodItemModel> foods, ApiPagination pagination});
typedef CategoriesResult = List<FoodCategoryModel>;

abstract class FoodsRemoteDataSource {
  Future<FoodsPage> getFoods({
    String? search,
    String? categoryId,
    bool? isArchived,
    int page = 1,
    int pageSize = 20,
  });

  Future<CategoriesResult> getFoodCategories();
}

class FoodsRemoteDataSourceImpl implements FoodsRemoteDataSource {
  const FoodsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<FoodsPage> getFoods({
    String? search,
    String? categoryId,
    bool? isArchived,
    int page = 1,
    int pageSize = 20,
  }) async {
    final effectiveSearch =
        (search == null || search.trim().isEmpty) ? null : search.trim();
    final effectiveCategory =
        (categoryId == null || categoryId.isEmpty) ? null : categoryId;
    final response = await _dio.get(
      ApiEndpoints.nutritionFoods,
      queryParameters: {
        'search': ?effectiveSearch,
        'categoryId': ?effectiveCategory,
        'isArchived': ?(isArchived?.toString()),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (foods: items, pagination: pagination);
  }

  @override
  Future<CategoriesResult> getFoodCategories() async {
    final response = await _dio.get(ApiEndpoints.nutritionFoodCategories);
    final data = response.data as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>? ?? [])
        .map((e) => FoodCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
