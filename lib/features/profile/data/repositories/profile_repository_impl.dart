import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:athletica/features/profile/domain/entities/client_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileRemoteDataSource _dataSource;

  @override
  Future<ApiResult<ClientProfileEntity>> getClientProfile() async {
    try {
      final model = await _dataSource.getClientProfile();
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}