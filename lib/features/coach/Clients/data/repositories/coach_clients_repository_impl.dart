import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_clients_remote_data_source.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:dio/dio.dart';

class CoachClientsRepositoryImpl implements CoachClientsRepository {
  const CoachClientsRepositoryImpl(this._dataSource);

  final CoachClientsRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<CoachClient>>> getClientsByTrainerId(
    String trainerId,
  ) async {
    try {
      final models = await _dataSource.getClientsByTrainerId(trainerId);
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CoachAssignedClient>>> getAssignedClients() async {
    try {
      final models = await _dataSource.getAssignedClients();
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ClientDetail>> getClientDetail(String clientId) async {
    try {
      final model = await _dataSource.getClientDetail(clientId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> removeAssignedClient(String coachClientId) async {
    try {
      await _dataSource.removeAssignedClient(coachClientId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteNutritionPlan(String planId) async {
    try {
      await _dataSource.deleteNutritionPlan(planId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
