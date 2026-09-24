import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/streak/data/datasources/streak_remote_data_source.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:athletica/features/streak/domain/repositories/streak_repository.dart';
import 'package:dio/dio.dart';

class StreakRepositoryImpl implements StreakRepository {
  const StreakRepositoryImpl(this._remoteDataSource);

  final StreakRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<StreakData>> getClientStreak() async {
    try {
      return ApiSuccess(await _remoteDataSource.getClientStreak());
    } on DioException catch (error) {
      return ApiError(mapDioException(error));
    } catch (error) {
      return ApiError(UnknownFailure(_message(error)));
    }
  }

  @override
  Future<ApiResult<StreakData>> getCoachClientStreak(
    String coachClientId,
  ) async {
    try {
      return ApiSuccess(
        await _remoteDataSource.getCoachClientStreak(coachClientId),
      );
    } on DioException catch (error) {
      return ApiError(mapDioException(error));
    } catch (error) {
      return ApiError(UnknownFailure(_message(error)));
    }
  }

  String _message(Object error) => error is StreakFetchException
      ? error.message
      : error.toString();
}
