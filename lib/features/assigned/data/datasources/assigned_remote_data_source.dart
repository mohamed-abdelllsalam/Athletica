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

    // Fetch workout plan the same way as nutrition.
    // Response: { "plan": {...} } or { "data": { "plan": {...} } };
    // plan == null (or no_active_plan_found) → workout stays null.
    AssignedWorkoutModel? workout;
    try {
      final workoutRes = await _dio.get(ApiEndpoints.workoutMyPlans);
      final plan = _extractPlan(workoutRes.data);
      if (plan != null) {
        workout = AssignedWorkoutModel.fromJson(plan);
      }
    } catch (_) {
      // Any error — leave workout as null
      workout = null;
    }

    return ClientAssignedModel(workout: workout, nutrition: nutrition);
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

/// Extracts the `plan` map from either `{ "plan": {...} }` or
/// `{ "data": { "plan": {...} } }`. Returns null when absent.
Map<String, dynamic>? _extractPlan(dynamic data) {
  if (data is! Map<String, dynamic>) return null;
  final nested = data['data'];
  final Map<String, dynamic> root = nested is Map<String, dynamic>
      ? nested
      : data;
  final plan = root['plan'];
  if (plan is Map<String, dynamic>) return plan;
  return null;
}
