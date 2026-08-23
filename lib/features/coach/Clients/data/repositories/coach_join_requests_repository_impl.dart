import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_join_requests_remote_data_source.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_join_requests_repository.dart';
import 'package:dio/dio.dart';

class CoachJoinRequestsRepositoryImpl implements CoachJoinRequestsRepository {
  const CoachJoinRequestsRepositoryImpl(this._dataSource);

  final CoachJoinRequestsRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<JoinRequest>>> getJoinRequests() async {
    try {
      final models = await _dataSource.getJoinRequests();
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> acceptJoinRequest(String requestId) async {
    try {
      await _dataSource.acceptJoinRequest(requestId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> rejectJoinRequest(String requestId) async {
    try {
      await _dataSource.rejectJoinRequest(requestId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
