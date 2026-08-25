import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/clients/data/models/coach_assigned_client_model.dart';
import 'package:athletica/features/coach/clients/data/models/coach_client_model.dart';
import 'package:dio/dio.dart';

abstract class CoachClientsRemoteDataSource {
  Future<List<CoachClientModel>> getClientsByTrainerId(String trainerId);

  /// `GET /coach/clients` — clients assigned via the coach-client flow.
  Future<List<CoachAssignedClientModel>> getAssignedClients();

  /// `DELETE /coach/clients/:id` — removes the assignment (cascades plans).
  ///
  /// NOTE: the live backend expects the **client profile id** in [clientId],
  /// NOT the roster relation id, despite the API doc saying otherwise.
  Future<void> removeAssignedClient(String clientId);
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

  @override
  Future<List<CoachAssignedClientModel>> getAssignedClients() async {
    final response = await _dio.get(ApiEndpoints.coachClients);
    final data =
        (response.data as Map<String, dynamic>? ?? {})['clients'] as List<dynamic>? ??
            [];
    return data
        .map((e) =>
            CoachAssignedClientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removeAssignedClient(String coachClientId) async {
    await _dio.delete(ApiEndpoints.coachClient(coachClientId));
  }
}
