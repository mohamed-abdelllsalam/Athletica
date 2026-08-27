import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      await TokenStorageService.instance.clearAll();
      await TokenStorageService.instance.saveToken(entity.token);
      await TokenStorageService.instance.saveRole(entity.user.primaryRole);
      if (entity.user.primaryRole == 'TRAINER') {
        await TokenStorageService.instance.saveTrainerId(entity.user.id);
      } else {
        await TokenStorageService.instance.saveClientId(entity.user.id);
      }
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
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signup(
        username: name,
        email: email,
        password: password,
        role: 'client',
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
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signup(
        username: name,
        email: email,
        password: password,
        role: 'coach',
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _remoteDataSource.verifyEmail(email: email, code: code);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> resendVerification({required String email}) async {
    try {
      await _remoteDataSource.resendVerification(email: email);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<String>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final message = await _remoteDataSource.requestPasswordReset(email: email);
      return ApiSuccess(message);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await _remoteDataSource.confirmPasswordReset(
        email: email,
        code: code,
        password: password,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapConfirmResetError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      debugPrint('[AuthRepo] Calling server logout...');
      await _remoteDataSource.logout();
      debugPrint('[AuthRepo] Server logout succeeded.');
    } on DioException catch (e) {
      debugPrint('[AuthRepo] Server logout failed: ${e.message}');
    } catch (e) {
      debugPrint('[AuthRepo] Server logout failed: $e');
    }
    await TokenStorageService.instance.clearAll();
    debugPrint('[AuthRepo] Local tokens cleared.');
    return const ApiSuccess(null);
  }

  @override
  Future<AuthStatus> getAuthStatus() async {
    final token = await TokenStorageService.instance.getToken();
    if (token == null) return const Unauthenticated();

    final role = await TokenStorageService.instance.getRole();

    if (role == 'TRAINER') {
      final isComplete = await TokenStorageService.instance.isProfileComplete();
      return isComplete ? const CoachReady() : const CoachProfileIncomplete();
    }

    // CLIENT: check local cache first, then verify with API
    bool isComplete = await TokenStorageService.instance.isProfileComplete();
    if (!isComplete) {
      isComplete = await _remoteDataSource.hasSubmittedClientAnswers();
      if (isComplete) await TokenStorageService.instance.saveProfileComplete();
    }
    return isComplete ? const ClientReady() : const ClientProfileIncomplete();
  }

  @override
  Future<void> markProfileComplete() =>
      TokenStorageService.instance.saveProfileComplete();

  String? _extractMessage(dynamic value) {
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.join(', ');
    return null;
  }

  String? _extractBackendMessage(Map<String, dynamic> data) {
    final message = _extractMessage(data['message']);
    if (message != null) return message;

    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      return details.map((detail) => detail.toString()).join(', ');
    }

    final error = _extractMessage(data['error']);
    if (error != null && error.toLowerCase() != 'validation failed') {
      return error;
    }
    return null;
  }

  AppFailure _mapConfirmResetError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No internet connection. Please try again.');
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? _extractBackendMessage(data)
          : null;
      if (message != null) {
        final lower = message.toLowerCase();
        if (lower.contains('expired')) {
          return const ServerFailure(
            'This verification code has expired. Please request a new code.',
          );
        }
        if (lower.contains('incorrect') ||
            lower.contains('invalid') ||
            lower.contains('wrong')) {
          return const ServerFailure(
            'The verification code is incorrect. Please try again.',
          );
        }
        return ServerFailure(message);
      }
      return const ServerFailure(
        'The verification code is incorrect. Please try again.',
      );
    }
    return _mapDioError(e);
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
        ? (_extractBackendMessage(data) ?? 'Something went wrong.')
        : 'Something went wrong. Please try again.';

    if (message.toLowerCase().contains('verify your email')) {
      return EmailNotVerifiedFailure(message);
    }
    if (statusCode == 401) return UnauthorizedFailure(message);
    return ServerFailure(message);
  }
}
