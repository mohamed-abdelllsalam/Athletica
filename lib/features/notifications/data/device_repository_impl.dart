import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:dio/dio.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/entities/device_registration.dart';

class DeviceDataSource {
  DeviceDataSource(this.dio, this.sessions);
  final Dio dio;
  final AuthSessionService sessions;
  CancelToken _cancel = CancelToken();
  void cancel() {
    _cancel.cancel('Session ended');
    _cancel = CancelToken();
  }

  Future<Response<dynamic>> post(
    String path,
    Map<String, dynamic> data,
    int generation,
  ) {
    if (sessions.current?.generation != generation) {
      throw StateError('Stale notification session');
    }
    return dio.post(
      path,
      data: data,
      cancelToken: _cancel,
      options: Options(extra: {'sessionGeneration': generation}),
    );
  }
}

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this.source);
  final DeviceDataSource source;
  @override
  void cancel() => source.cancel();

  AppFailure _failure(Object error) {
    if (error is DioException) {
      if (isConnectivityException(error)) return mapDioException(error);
      final status = error.response?.statusCode;
      final body = error.response?.data;
      if (status == 409 &&
          body is Map &&
          (body['error'] == 'device_conflict' ||
              body['code'] == 'device_conflict')) {
        return const DeviceConflictFailure();
      }
      if (status == 400) {
        return const ServerFailure('Device registration validation failed.');
      }
      if (status == 401) return const UnauthorizedFailure('Session expired.');
      if (status == null || status == 429 || status >= 500) {
        return const ServerFailure(
          'Notification service temporarily unavailable.',
          retryable: true,
        );
      }
    }
    return const ServerFailure('Notification service request failed.');
  }

  @override
  Future<ApiResult<DeviceRegistration>> register(
    String token,
    String platform,
    String deviceId,
    int generation,
  ) async {
    if (token.trim().length < 100 ||
        token.trim().length > 4096 ||
        !{'android', 'ios', 'web'}.contains(platform)) {
      return const ApiError(
        ServerFailure('Device registration validation failed.'),
      );
    }
    try {
      final response = await source.post(ApiEndpoints.devices, {
        'fcm_token': token.trim(),
        'platform': platform,
        'device_id': deviceId,
      }, generation);
      final body = response.data;
      if (body is! Map ||
          body['device'] is! Map ||
          (body['device'] as Map)['replaced'] is! bool) {
        throw const FormatException('Invalid device registration response');
      }
      return ApiSuccess(
        DeviceRegistration(
          replaced: (body['device'] as Map)['replaced'] as bool,
        ),
      );
    } catch (e) {
      return ApiError(_failure(e));
    }
  }

  @override
  Future<ApiResult<bool>> heartbeat(String deviceId, int generation) async {
    try {
      final response = await source.post(ApiEndpoints.deviceHeartbeat, {
        'device_id': deviceId,
      }, generation);
      final data = response.data;
      if (data is! Map || data['is_active'] is! bool) {
        throw const FormatException('Invalid heartbeat response');
      }
      return ApiSuccess(data['is_active'] as bool);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 &&
          e.response?.data is Map &&
          e.response?.data['error'] == 'device_not_found') {
        return const ApiSuccess(false);
      }
      return ApiError(_failure(e));
    } catch (e) {
      return ApiError(_failure(e));
    }
  }
}
