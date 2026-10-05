import 'package:athletica/core/services/auth_session_service.dart';
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

  final AuthSessionService _sessions;
  const AuthRepositoryImpl(this._remoteDataSource, this._sessions);

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
      await _saveAuthResponse(entity);
      return ApiSuccess(entity);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<AuthResponseEntity>> loginWithGoogle({
    required String idToken,
    String? role,
  }) async {
    try {
      final model = await _remoteDataSource.loginWithGoogle(
        idToken: idToken,
        role: role,
      );
      final entity = model.toEntity();
      await _saveAuthResponse(entity);
      return ApiSuccess(entity);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  Future<void> _saveAuthResponse(AuthResponseEntity entity) async {
    await _sessions.end();
    await TokenStorageService.instance.clearAll();
    await TokenStorageService.instance.saveToken(entity.token);
    await TokenStorageService.instance.saveRole(entity.user.primaryRole);
    if (entity.user.primaryRole == 'TRAINER') {
      await TokenStorageService.instance.saveTrainerId(entity.user.id);
    } else if (entity.user.primaryRole == 'CLIENT') {
      await TokenStorageService.instance.saveClientId(entity.user.id);
    } else {
      throw const FormatException('Unsupported account role from server.');
    }
    _sessions.start(entity.user.id, entity.user.primaryRole);
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
      final message = await _remoteDataSource.requestPasswordReset(
        email: email,
      );
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
    await _sessions.end();
    try {
      await _remoteDataSource.logout();
    } on DioException {
      // Server logout is best-effort; local credentials are always removed.
      debugPrint(
        'Backend logout failed; device deletion may need retry on the server.',
      );
    } catch (e) {
      // Server logout is best-effort; local credentials are always removed.
      debugPrint('Backend logout unavailable; local session will be cleared.');
    }
    await TokenStorageService.instance.clearAll();
    return const ApiSuccess(null);
  }

  @override
  Future<AuthStatus> getAuthStatus() async {
    final token = await TokenStorageService.instance.getToken();
    if (token == null) return const Unauthenticated();

    final role = await TokenStorageService.instance.getRole();
    final userId = role == 'TRAINER'
        ? await TokenStorageService.instance.getTrainerId()
        : await TokenStorageService.instance.getClientId();
    if (userId != null && (role == 'TRAINER' || role == 'CLIENT')) {
      _sessions.start(userId, role!);
    }

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

  @override
  Future<ApiResult<bool>> checkClientProfileCompletion() async {
    try {
      final isComplete = await _remoteDataSource.checkClientProfileCompletion();
      return ApiSuccess(isComplete);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

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
    if (statusCode == 400 && _hasDetail(data, 'role_invalid')) {
      return const GoogleRoleRequiredFailure();
    }
    if (statusCode == 400 && _hasDetail(data, 'idToken_required')) {
      return const GoogleIdTokenRequiredFailure();
    }
    if (statusCode == 401 &&
        data is Map &&
        data['error']?.toString().toLowerCase() == 'invalid token') {
      return const GoogleInvalidTokenFailure();
    }
    final message = data is Map<String, dynamic>
        ? (_extractBackendMessage(data) ?? 'Something went wrong.')
        : 'Something went wrong. Please try again.';

    if (message.toLowerCase().contains('verify your email')) {
      return EmailNotVerifiedFailure(message);
    }
    if (statusCode == 401) return UnauthorizedFailure(message);
    return ServerFailure(message);
  }

  bool _hasDetail(dynamic data, String expected) =>
      data is Map &&
      data['details'] is List &&
      (data['details'] as List).any((detail) => detail.toString() == expected);
}
