import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/clients/data/models/client_detail_model.dart';
import 'package:athletica/features/coach/clients/data/models/coach_assigned_client_model.dart';
import 'package:athletica/features/coach/clients/data/models/coach_client_model.dart';
import 'package:dio/dio.dart';

abstract class CoachClientsRemoteDataSource {
  Future<List<CoachClientModel>> getClientsByTrainerId(String trainerId);

  /// `GET /coach/clients` — clients assigned via the coach-client flow.
  Future<List<CoachAssignedClientModel>> getAssignedClients();

  /// `GET /coach/clients/:id` — detailed client profile with plans,
  /// answers and totals. `:id` is the nested `client.id`
  /// (`client_profiles.id`), not the top-level assignment id.
  Future<ClientDetailModel> getClientDetail(String clientId);

  /// `DELETE /coach/clients/:id` — removes the assignment (cascades plans).
  Future<void> removeAssignedClient(String clientId);

  /// `DELETE /nutrition/plans/:planId` — deactivates the plan.
  Future<void> deleteNutritionPlan(String planId);

  /// `DELETE /workout/plans/:planId` — deactivates the plan.
  Future<void> deleteWorkoutPlan(String planId);
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
  Future<ClientDetailModel> getClientDetail(String clientId) async {
    final response = await _dio.get(ApiEndpoints.coachClient(clientId));
    return ClientDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeAssignedClient(String clientId) async {
    await _dio.delete(ApiEndpoints.coachClient(clientId));
  }

  @override
  Future<void> deleteNutritionPlan(String planId) async {
    await _dio.delete(ApiEndpoints.nutritionPlan(planId));
  }

  @override
  Future<void> deleteWorkoutPlan(String planId) async {
    await _dio.delete(ApiEndpoints.workoutPlan(planId));
  }
}
