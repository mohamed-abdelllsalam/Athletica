import 'package:athletica/core/helper/app_navigator_key.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/session_expired_guard.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static final SessionExpiredGuard _sessionExpiredGuard =
      SessionExpiredGuard();

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicAuth = ApiEndpoints.isPublicAuthPath(options.uri.path);
          if (!isPublicAuth) {
            final token = await TokenStorageService.instance.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final wasAuthenticatedRequest =
              requestOptions.headers['Authorization'] != null &&
                  !ApiEndpoints.isPublicAuthPath(requestOptions.uri.path);
          final isSessionExpired =
              error.response?.statusCode == 401 && wasAuthenticatedRequest;
          if (isSessionExpired) {
            // Single-flight: a burst of concurrent 401s (e.g. the dashboard
            // firing 5-6 authenticated requests at once) must produce ONE
            // message + ONE navigation, not one per request. Duplicates still
            // propagate as UnauthorizedFailure but show no global UI.
            if (!_sessionExpiredGuard.shouldHandle(DateTime.now())) {
              handler.next(error);
              return;
            }
            try {
              // Navigate first (sync) so old routes/listeners are disposed
              // before their cubits emit UnauthorizedFailure — per-screen UI
              // then never shows its own duplicate message.
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                OnBoardingView.routeName,
                (_) => false,
              );
              await TokenStorageService.instance.clearAll();
              final context = appNavigatorKey.currentContext;
              if (context != null && context.mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Session expired, please login again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            } finally {
              _sessionExpiredGuard.complete();
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  Dio get dio => _dio;
}
