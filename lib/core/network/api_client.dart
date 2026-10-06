import 'package:athletica/core/errors/api_error_mapper.dart';
import 'dart:async';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/helper/app_navigator_key.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/session_expired_guard.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static final SessionExpiredGuard _sessionExpiredGuard = SessionExpiredGuard();

  late final Dio _dio;
  late final Dio _rawDio;

  Completer<bool>? _refreshing;

  // Optional transports allow deterministic request/refresh failure tests.
  void init({Dio? transport, Dio? refreshTransport}) {
    final options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    );

    _rawDio = refreshTransport ?? Dio(options);
    _dio = transport ?? Dio(options);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.data is FormData) {
            options.headers.remove(Headers.contentTypeHeader);
          }

          final generation = options.extra['sessionGeneration'];

          if (generation != null &&
              sl<AuthSessionService>().current?.generation != generation) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
                message: 'Stale push session',
              ),
            );
            return;
          }

          final isPublicAuth = ApiEndpoints.isPublicAuthPath(options.uri.path);

          if (!isPublicAuth) {
            final token = await TokenStorageService.instance.getToken();

            if (token != null) {
              if (generation != null &&
                  sl<AuthSessionService>().current?.generation != generation) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.cancel,
                    message: 'Stale push session',
                  ),
                );
                return;
              }

              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;

          final isPublicAuth = ApiEndpoints.isPublicAuthPath(
            requestOptions.uri.path,
          );

          final generation = requestOptions.extra['sessionGeneration'];

          if (generation != null &&
              sl<AuthSessionService>().current?.generation != generation) {
            handler.next(error);
            return;
          }

          final isSessionExpired =
              (error.response?.statusCode == 401 ||
                  _isAuthenticationRequiredBody(error.response?.data)) &&
              !isPublicAuth;

          if (isSessionExpired) {
            if (requestOptions.extra['authRetry'] == true) {
              await _expireSession();
              handler.next(error);
              return;
            }

            final bool refreshed;
            try {
              refreshed = await _refreshOnce();
            } on DioException catch (refreshError) {
              // A failed transport cannot invalidate stored credentials.
              handler.next(refreshError);
              return;
            }
            if (refreshed) {
              final token = await TokenStorageService.instance.getToken();

              if (token == null) {
                await _expireSession();
                handler.next(error);
                return;
              }

              requestOptions.headers['Authorization'] = 'Bearer $token';
              requestOptions.extra['authRetry'] = true;

              try {
                handler.resolve(await _dio.fetch(requestOptions));
              } catch (retryError) {
                handler.next(
                  retryError is DioException
                      ? retryError
                      : DioException(
                          requestOptions: requestOptions,
                          error: retryError,
                        ),
                );
              }

              return;
            }

            await _expireSession();
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          filter: (options, args) =>
              !options.path.contains('/messaging/') &&
              !options.path.startsWith('messaging/') &&
              !options.path.startsWith('devices') &&
              !options.uri.path.split('/').contains('notifications') &&
              !options.path.startsWith('auth/') &&
              !options.path.endsWith(ApiEndpoints.ablyToken) &&
              !options.path.endsWith(ApiEndpoints.coachAchievements),
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<bool> _refreshOnce() {
    final existing = _refreshing;

    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<bool>();
    _refreshing = completer;

    () async {
      try {
        final refreshToken = await TokenStorageService.instance
            .getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          completer.complete(false);
          return;
        }

        final response = await _rawDio.post(
          ApiEndpoints.refresh,
          data: {'refreshToken': refreshToken},
          options: Options(validateStatus: (_) => true),
        );

        if (response.statusCode != 200 ||
            response.data is! Map<String, dynamic>) {
          completer.complete(false);
          return;
        }

        final body = response.data as Map<String, dynamic>;

        final access = body['token'];
        final rotated = body['refreshToken'];

        if (access is! String ||
            access.isEmpty ||
            rotated is! String ||
            rotated.isEmpty) {
          completer.complete(false);
          return;
        }

        await TokenStorageService.instance.saveTokens(
          accessToken: access,
          refreshToken: rotated,
          startsNewSession: false,
        );

        completer.complete(true);
      } on DioException catch (error, stack) {
        if (!completer.isCompleted) {
          if (isConnectivityException(error)) {
            completer.completeError(error, stack);
          } else {
            completer.complete(false);
          }
        }
      } catch (_) {
        if (!completer.isCompleted) completer.complete(false);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }

  Future<void> _expireSession() async {
    if (!_sessionExpiredGuard.shouldHandle(DateTime.now())) {
      return;
    }

    try {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        SignInView.routeName,
        (_) => false,
        arguments: const {'sessionExpired': true},
      );

      unawaited(sl<AuthSessionService>().end());

      await TokenStorageService.instance.clearAll();
    } finally {
      _sessionExpiredGuard.complete();
    }
  }
}

/// Returns true when the backend body explicitly says authentication is
/// required (e.g. `{"error": "auth_required"}` or
/// `{"message": "Authentication required"}`), even if the status code
/// is not exactly 401.
bool _isAuthenticationRequiredBody(dynamic data) {
  if (data is! Map) {
    return false;
  }

  final values = [
    data['error']?.toString().toLowerCase() ?? '',
    data['message']?.toString().toLowerCase() ?? '',
  ];

  return values.any(
    (v) =>
        v.contains('auth_required') ||
        v.contains('authentication required') ||
        v == 'auth required',
  );
}
