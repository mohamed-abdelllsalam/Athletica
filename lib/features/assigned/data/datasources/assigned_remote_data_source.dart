import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/assigned/data/models/client_assigned_model.dart';
import 'package:dio/dio.dart';

abstract class AssignedRemoteDataSource {
  Future<ClientAssignedModel> getAssignedPlans();
  Future<void> assignWorkoutTemplate(String templateId);
  Future<void> assignNutritionTemplate(String templateId);
}

class AssignedRemoteDataSourceImpl implements AssignedRemoteDataSource {
  const AssignedRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ClientAssignedModel> getAssignedPlans() async {
    AssignedNutritionModel? nutrition;

    // Fetch nutrition plan from existing endpoint
    try {
      final nutritionRes = await _dio.get(ApiEndpoints.nutritionMyPlans);
      final data = nutritionRes.data;
      if (data is Map<String, dynamic>) {
        // Response: { "plan": { id, title, ... } } or { "plan": null }
        final plan = data['plan'];
        if (plan is Map<String, dynamic>) {
          nutrition = AssignedNutritionModel.fromJson(plan);
        }
        // plan == null → nutrition stays null
      }
    } catch (_) {
      // Any error — leave nutrition as null
      nutrition = null;
    }

    // Workout: no endpoint exists yet, always null
    return ClientAssignedModel(workout: null, nutrition: nutrition);
  }

  @override
  Future<void> assignWorkoutTemplate(String templateId) async {
    await _dio.post(ApiEndpoints.assignWorkoutTemplate(templateId));
  }

  @override
  Future<void> assignNutritionTemplate(String templateId) async {
    await _dio.post(
      ApiEndpoints.assignNutritionToClient(templateId),
      data: <String, dynamic>{},
    );
  }
}
