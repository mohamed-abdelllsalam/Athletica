import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/profile/data/datasources/coach_profile_remote_data_source.dart';
import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';
import 'package:athletica/features/coach/profile/domain/repositories/coach_profile_repository.dart';
import 'package:dio/dio.dart';

class CoachProfileRepositoryImpl implements CoachProfileRepository {
  const CoachProfileRepositoryImpl(this._dataSource);

  final CoachProfileRemoteDataSource _dataSource;

  @override
  Future<ApiResult<CoachProfileEntity>> getCoachProfile(
    String trainerId,
  ) async {
    try {
      final model = await _dataSource.getCoachProfile(trainerId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
