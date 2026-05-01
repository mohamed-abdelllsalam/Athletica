import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/data/datasources/nutrition_templates_remote_data_source.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_day.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_item.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';
import 'package:dio/dio.dart';

class NutritionTemplatesRepositoryImpl implements NutritionTemplatesRepository {
  const NutritionTemplatesRepositoryImpl(this._dataSource);

  final NutritionTemplatesRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<NutritionTemplate>>> getNutritionTemplates() async {
    try {
      final models = await _dataSource.getNutritionTemplates();
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplate>> createNutritionTemplate({
    required String title,
    required String description,
    required bool isPublic,
    required int dailyTargetCalories,
    required int dailyTargetProtein,
    required int dailyTargetCarbs,
    required int dailyTargetFats,
  }) async {
    try {
      final model = await _dataSource.createNutritionTemplate(
        title: title,
        description: description,
        isPublic: isPublic,
        dailyTargetCalories: dailyTargetCalories,
        dailyTargetProtein: dailyTargetProtein,
        dailyTargetCarbs: dailyTargetCarbs,
        dailyTargetFats: dailyTargetFats,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplateDay>> createNutritionTemplateDay({
    required String templateId,
    required String name,
    required int dayNumber,
  }) async {
    try {
      final model = await _dataSource.createNutritionTemplateDay(
        templateId: templateId,
        name: name,
        dayNumber: dayNumber,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<NutritionTemplateItem>> createNutritionTemplateItem({
    required String dayId,
    required String foodId,
    required int grams,
  }) async {
    try {
      final model = await _dataSource.createNutritionTemplateItem(
        dayId: dayId,
        foodId: foodId,
        grams: grams,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
