import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/client_coach/data/datasources/client_coach_remote_data_source.dart';
import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';
import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';
import 'package:athletica/features/client_coach/domain/repositories/client_coach_repository.dart';
import 'package:dio/dio.dart';

class ClientCoachRepositoryImpl implements ClientCoachRepository {
  const ClientCoachRepositoryImpl(this._dataSource);

  final ClientCoachRemoteDataSource _dataSource;

  @override
  Future<ApiResult<CoachLinkRequest>> submitInviteToken(String token) async {
    try {
      final model = await _dataSource.submitInviteToken(token);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<AssignedCoach?>> getMyCoach() async {
    try {
      final model = await _dataSource.getMyCoach();
      return ApiSuccess(model?.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> leaveCoach() async {
    try {
      await _dataSource.leaveCoach();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
