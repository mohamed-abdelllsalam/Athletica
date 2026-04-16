import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> registerTrainer({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

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
  Future<void> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      ApiEndpoints.registerClient,
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<void> registerTrainer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      ApiEndpoints.registerTrainer,
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}
