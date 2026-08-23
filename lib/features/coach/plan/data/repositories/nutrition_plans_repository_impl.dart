import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/plan/data/datasources/nutrition_plans_remote_data_source.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_nutrition_plan.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';
import 'package:dio/dio.dart';

class NutritionPlansRepositoryImpl implements NutritionPlansRepository {
  const NutritionPlansRepositoryImpl(this._dataSource);

  final NutritionPlansRemoteDataSource _dataSource;

  @override
  Future<NutritionPlansPageResult> getNutritionPlans({
    int page = 1,
    int pageSize = 20,
    String? clientId,
    bool? isActive,
  }) async {
    try {
      final (:plans, :pagination) = await _dataSource.getNutritionPlans(
        page: page,
        pageSize: pageSize,
        clientId: clientId,
        isActive: isActive,
      );
      return ApiSuccess((
        plans: plans.map((m) => m.toEntity()).toList(),
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<CoachNutritionPlan>> getNutritionPlan(String planId) async {
    try {
      final model = await _dataSource.getNutritionPlan(planId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteNutritionPlan(String planId) async {
    try {
      await _dataSource.deleteNutritionPlan(planId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplateMeal>> addPlanMeal(
    String planId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) async {
    try {
      final model = await _dataSource.addPlanMeal(
        planId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> updatePlanMeal(
    String planId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) async {
    try {
      await _dataSource.updatePlanMeal(
        planId,
        mealId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deletePlanMeal(String planId, String mealId) async {
    try {
      await _dataSource.deletePlanMeal(planId, mealId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> reorderPlanMeals(
    String planId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) async {
    try {
      await _dataSource.reorderPlanMeals(planId, mealOrders);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> addPlanFood(
    String planId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) async {
    try {
      await _dataSource.addPlanFood(
        planId,
        mealId,
        foodId: foodId,
        quantity: quantity,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> updatePlanFood(
    String planId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) async {
    try {
      await _dataSource.updatePlanFood(
        planId,
        mealId,
        relationFoodId,
        quantity: quantity,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> removePlanFood(
    String planId,
    String mealId,
    String relationFoodId,
  ) async {
    try {
      await _dataSource.removePlanFood(planId, mealId, relationFoodId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
