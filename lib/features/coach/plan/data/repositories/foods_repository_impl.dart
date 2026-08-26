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
  Map<String, String>? _categoryLabelsCache;

  /// Category display labels resolved once so food cards keep their
  /// emoji/icon mapping (matched against both en/ar labels).
  Future<Map<String, String>> _categoryLabels() async {
    if (_categoryLabelsCache != null) return _categoryLabelsCache!;
    final models = await _dataSource.getFoodCategories();
    _categoryLabelsCache = {
      for (final c in models) c.id: c.toEntity().displayName,
    };
    return _categoryLabelsCache!;
  }

  @override
  Future<FoodsPageResult> getFoods({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Category labels are resolved once so food cards keep their emoji.
      final labelById = await _categoryLabels();
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
                .copyWithCategoryName(labelById[m.categoryId] ?? '')
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
