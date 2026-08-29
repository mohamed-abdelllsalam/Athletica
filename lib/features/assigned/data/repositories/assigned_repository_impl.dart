import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/assigned/data/datasources/assigned_remote_data_source.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/domain/repositories/assigned_repository.dart';
import 'package:dio/dio.dart';

class AssignedRepositoryImpl implements AssignedRepository {
  const AssignedRepositoryImpl(this._dataSource);

  final AssignedRemoteDataSource _dataSource;

  @override
  Future<ApiResult<ClientAssigned>> getAssignedPlans() async {
    try {
      final model = await _dataSource.getAssignedPlans();
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> assignWorkoutTemplate(String templateId) async {
    try {
      await _dataSource.assignWorkoutTemplate(templateId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> assignNutritionTemplate(String templateId) async {
    try {
      await _dataSource.assignNutritionTemplate(templateId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
