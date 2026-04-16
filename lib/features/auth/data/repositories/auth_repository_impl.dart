import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<AuthResponseEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      final entity = model.toEntity();
      await TokenStorageService.instance.saveToken(entity.token);
      await TokenStorageService.instance.saveRole(entity.user.primaryRole);
      return ApiSuccess(entity);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.registerClient(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> registerTrainer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.registerTrainer(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await TokenStorageService.instance.clearAll();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  AppFailure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No internet connection. Please try again.');
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message'] as String? ??
              data['error'] as String? ??
              'Something went wrong.')
        : e.message ?? 'Something went wrong.';

    if (statusCode == 401) return UnauthorizedFailure(message);
    return ServerFailure(message);
  }
}
