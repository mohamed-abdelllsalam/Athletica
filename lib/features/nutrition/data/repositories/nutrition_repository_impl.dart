import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/data/datasources/nutrition_remote_data_source.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:dio/dio.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  const NutritionRepositoryImpl(this._dataSource);

  final NutritionRemoteDataSource _dataSource;

  @override
  Future<ApiResult<TodayMeals>> getTodayMeals() async {
    try {
      final model = await _dataSource.getTodayMeals();
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<TodayMeals>> completeMeal(String mealLogId) async {
    try {
      final model = await _dataSource.completeMeal(mealLogId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<TodayMeals>> uncompleteMeal(String mealLogId) async {
    try {
      final model = await _dataSource.uncompleteMeal(mealLogId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
