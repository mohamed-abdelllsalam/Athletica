import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<void> verifyEmail({required String email, required String code});

  Future<void> resendVerification({required String email});

  Future<String> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  });

  Future<bool> hasSubmittedClientAnswers();

  /// Returns `true` if the client's profile/answers are complete.
  /// Throws on network/server errors so the caller can distinguish
  /// "incomplete profile" from "request failed".
  Future<bool> checkClientProfileCompletion();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post(
      ApiEndpoints.signup,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _dio.post(
      ApiEndpoints.verifyEmail,
      data: {'email': email, 'code': code},
    );
  }

  @override
  Future<void> resendVerification({required String email}) async {
    await _dio.post(ApiEndpoints.resendVerification, data: {'email': email});
  }

  @override
  Future<String> requestPasswordReset({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return '';
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  }) async {
    await _dio.post(
      ApiEndpoints.confirmPasswordReset,
      data: {'email': email, 'code': code, 'password': password},
    );
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  @override
  Future<bool> hasSubmittedClientAnswers() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientAnswers);
      final data = response.data as Map<String, dynamic>?;
      final answers = data?['answers'] as List<dynamic>? ?? const [];
      return answers.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> checkClientProfileCompletion() async {
    final response = await _dio.get(ApiEndpoints.clientAnswers);
    final data = response.data as Map<String, dynamic>?;
    final answers = data?['answers'] as List<dynamic>? ?? const [];
    return answers.isNotEmpty;
  }
}
