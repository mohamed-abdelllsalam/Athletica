import 'package:athletica/core/helper/app_navigator_key.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

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
            await TokenStorageService.instance.clearAll();
            final context = appNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session expired, please login again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
              OnBoardingView.routeName,
              (_) => false,
            );
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
