import 'dart:io';

import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:dio/dio.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  const AchievementsRepositoryImpl(this._dataSource);

  final AchievementsRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<CoachAchievement>>> getCoachAchievements() async {
    try {
      final models = await _dataSource.getCoachAchievements();
      return ApiSuccess(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<CoachAchievement>> uploadCoachAchievement({
    required String title,
    required File file,
  }) async {
    try {
      final model = await _dataSource.uploadCoachAchievement(
        title: title,
        file: file,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteCoachAchievement(String id) async {
    try {
      await _dataSource.deleteCoachAchievement(id);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CoachAchievement>>>
  getAssignedCoachAchievements() async {
    try {
      final models = await _dataSource.getAssignedCoachAchievements();
      return ApiSuccess(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
