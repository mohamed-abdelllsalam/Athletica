import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/data/datasources/nutrition_templates_remote_data_source.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';
import 'package:dio/dio.dart';

class NutritionTemplatesRepositoryImpl
    implements NutritionTemplatesRepository {
  const NutritionTemplatesRepositoryImpl(this._dataSource);

  final NutritionTemplatesRemoteDataSource _dataSource;

  TemplatesPageResult _mapPageError(DioException e) =>
      ApiError(mapDioException(e));

  @override
  Future<TemplatesPageResult> getNutritionTemplates({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final (:templates, :pagination) = await _dataSource
          .getNutritionTemplates(page: page, pageSize: pageSize);
      return ApiSuccess((
        templates: templates.map((m) => m.toEntity()).toList(),
        pagination: pagination,
      ));
    } on DioException catch (e) {
      return _mapPageError(e);
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplate>> createNutritionTemplate({
    required String title,
    required String description,
  }) async {
    try {
      final model = await _dataSource.createNutritionTemplate(
        title: title,
        description: description,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplate>> getNutritionTemplate(
    String templateId,
  ) async {
    try {
      final model = await _dataSource.getNutritionTemplate(templateId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> updateNutritionTemplate(
    String templateId, {
    String? title,
    String? description,
  }) async {
    try {
      await _dataSource.updateNutritionTemplate(
        templateId,
        title: title,
        description: description,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteNutritionTemplate(String templateId) async {
    try {
      await _dataSource.deleteNutritionTemplate(templateId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplateMeal>> addTemplateMeal(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) async {
    try {
      final model = await _dataSource.addTemplateMeal(
        templateId,
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
  Future<ApiResult<void>> updateTemplateMeal(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) async {
    try {
      await _dataSource.updateTemplateMeal(
        templateId,
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
  Future<ApiResult<void>> deleteTemplateMeal(
    String templateId,
    String mealId,
  ) async {
    try {
      await _dataSource.deleteTemplateMeal(templateId, mealId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> reorderTemplateMeals(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) async {
    try {
      await _dataSource.reorderTemplateMeals(templateId, mealOrders);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> addTemplateFood(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) async {
    try {
      await _dataSource.addTemplateFood(
        templateId,
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
  Future<ApiResult<void>> updateTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) async {
    try {
      await _dataSource.updateTemplateFood(
        templateId,
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
  Future<ApiResult<void>> removeTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId,
  ) async {
    try {
      await _dataSource.removeTemplateFood(
          templateId, mealId, relationFoodId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> assignNutritionTemplate(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  }) async {
    try {
      await _dataSource.assignNutritionTemplate(
        templateId,
        coachClientId: coachClientId,
        title: title,
        description: description,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AssignedClient>>> getAssignedClients() async {
    try {
      final models = await _dataSource.getAssignedClients();
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> removeAssignedClient(String clientId) async {
    try {
      await _dataSource.removeAssignedClient(clientId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
