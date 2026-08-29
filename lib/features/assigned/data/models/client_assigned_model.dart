import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';

class ClientAssignedModel {
  const ClientAssignedModel({
    this.workout,
    this.nutrition,
  });

  final AssignedWorkoutModel? workout;
  final AssignedNutritionModel? nutrition;

  factory ClientAssignedModel.fromJson(Map<String, dynamic> json) {
    // Handle nested "data" wrapper if present
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final workoutData = data['workout'] as Map<String, dynamic>?;
    final nutritionData = data['nutrition'] as Map<String, dynamic>?;

    return ClientAssignedModel(
      workout: workoutData != null && workoutData.isNotEmpty
          ? AssignedWorkoutModel.fromJson(workoutData)
          : null,
      nutrition: nutritionData != null && nutritionData.isNotEmpty
          ? AssignedNutritionModel.fromJson(nutritionData)
          : null,
    );
  }

  ClientAssigned toEntity() => ClientAssigned(
        workout: workout?.toEntity(),
        nutrition: nutrition?.toEntity(),
      );
}

class AssignedWorkoutModel {
  const AssignedWorkoutModel({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  factory AssignedWorkoutModel.fromJson(Map<String, dynamic> json) {
    return AssignedWorkoutModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  AssignedWorkout toEntity() => AssignedWorkout(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
      );
}

class AssignedNutritionModel {
  const AssignedNutritionModel({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  factory AssignedNutritionModel.fromJson(Map<String, dynamic> json) {
    return AssignedNutritionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  AssignedNutrition toEntity() => AssignedNutrition(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
      );
}
