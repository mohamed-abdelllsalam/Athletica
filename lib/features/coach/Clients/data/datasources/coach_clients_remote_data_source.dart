import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/clients/data/models/coach_client_model.dart';
import 'package:dio/dio.dart';

abstract class CoachClientsRemoteDataSource {
  Future<List<CoachClientModel>> getClientsByTrainerId(String trainerId);
}

class CoachClientsRemoteDataSourceImpl implements CoachClientsRemoteDataSource {
  const CoachClientsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CoachClientModel>> getClientsByTrainerId(
    String trainerId,
  ) async {
    final response = await _dio.get(ApiEndpoints.trainerClients(trainerId));
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => CoachClientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
