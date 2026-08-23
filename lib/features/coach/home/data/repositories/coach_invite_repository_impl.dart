import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/data/datasources/coach_invite_remote_data_source.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:athletica/features/coach/home/domain/repositories/coach_invite_repository.dart';
import 'package:dio/dio.dart';

class CoachInviteRepositoryImpl implements CoachInviteRepository {
  const CoachInviteRepositoryImpl(this._dataSource);

  final CoachInviteRemoteDataSource _dataSource;

  @override
  Future<ApiResult<CoachInviteCode>> createInviteCode() async {
    try {
      final model = await _dataSource.createInviteCode();
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> revokeInviteCode() async {
    try {
      await _dataSource.revokeInviteCode();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
