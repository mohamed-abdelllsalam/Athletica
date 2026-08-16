import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/data/datasources/foods_remote_data_source.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';
import 'package:dio/dio.dart';

class FoodsRepositoryImpl implements FoodsRepository {
  const FoodsRepositoryImpl(this._dataSource);

  final FoodsRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<FoodItem>>> getFoods({int limit = 100}) async {
    try {
      final models = await _dataSource.getFoods(limit: limit);
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
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
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
