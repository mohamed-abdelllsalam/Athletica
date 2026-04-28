import 'package:athletica/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class InfoRemoteDataSource {
  Future<void> submitAnswers(Map<String, String> answers);
}

class InfoRemoteDataSourceImpl implements InfoRemoteDataSource {
  const InfoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> submitAnswers(Map<String, String> answers) async {
    await _dio.post(
      ApiEndpoints.clientIntakeAnswers,
      data: {'answers': answers},
    );
  }
}
