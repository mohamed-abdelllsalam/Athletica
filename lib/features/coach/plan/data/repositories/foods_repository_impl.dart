import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/data/datasources/foods_remote_data_source.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';
import 'package:dio/dio.dart';

class FoodsRepositoryImpl implements FoodsRepository {
  FoodsRepositoryImpl(this._dataSource);

  final FoodsRemoteDataSource _dataSource;
  Map<String, String>? _categoryNamesCache;

  Future<Map<String, String>> _categoryNames() async {
    if (_categoryNamesCache != null) return _categoryNamesCache!;
    final models = await _dataSource.getFoodCategories();
    _categoryNamesCache = {for (final c in models) c.id: c.name};
    return _categoryNamesCache!;
  }

  @override
  Future<FoodsPageResult> getFoods({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Category names are resolved once so food cards keep their emoji/icon.
      final nameById = await _categoryNames();
      final page_ = await _dataSource.getFoods(
        search: search,
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
      final foods = page_
          .foods
          .map(
            (m) => m
                .copyWithCategoryName(nameById[m.categoryId] ?? '')
                .toEntity(),
          )
          .toList();
      return ApiSuccess((foods: foods, pagination: page_.pagination));
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<FoodCategory>>> getFoodCategories() async {
    try {
      final models = await _dataSource.getFoodCategories();
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
