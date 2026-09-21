import 'package:athletica/core/utils/goal_format.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.location,
    this.profileImage,
    this.bio = '',
    this.specialization = '',
    this.specializationDisplay,
    this.role,
    this.gender,
    this.birthDate,
    this.height,
    this.weight,
    this.goal,
    this.createdAt,
    this.updatedAt,
    this.assignedAt,
    this.workoutPlan,
    this.nutritionPlan,
  });

  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? location;
  final String? profileImage;
  final String bio;
  final String specialization;
  final Map<String, String>? specializationDisplay;
  final String? role;
  final String? gender;
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Top-level `assigned_at` from `GET /profile`; null when absent/null.
  final DateTime? assignedAt;

  /// Top-level plan summaries from `GET /profile`; null when absent/null.
  final AssignedWorkoutPlanSummary? workoutPlan;
  final AssignedNutritionPlanSummary? nutritionPlan;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    final hasUserWrapper = json.containsKey('user');

    final effectiveProfile = hasUserWrapper ? profile : json;

    return UserProfileModel(
      id: hasUserWrapper
          ? (user['id']?.toString() ?? '')
          : (effectiveProfile['id']?.toString() ?? ''),
      email: hasUserWrapper
          ? (user['email']?.toString() ?? '')
          : '',
      name: hasUserWrapper
          ? (user['username']?.toString() ?? '')
          : (effectiveProfile['username']?.toString() ?? ''),
      phoneNumber: effectiveProfile['phone_number']?.toString(),
      location: effectiveProfile['location']?.toString(),
      profileImage: effectiveProfile['profile_image']?.toString(),
      bio: effectiveProfile['bio']?.toString() ?? '',
      specialization: effectiveProfile['specialization']?.toString() ?? '',
      specializationDisplay: effectiveProfile['specialization_display'] != null
          ? Map<String, String>.from(
              effectiveProfile['specialization_display'] as Map)
          : null,
      role: user['role']?.toString(),
      gender: effectiveProfile['gender']?.toString(),
      birthDate: effectiveProfile['birth_date'] != null
          ? DateTime.tryParse(effectiveProfile['birth_date'] as String)
          : null,
      height: switch (effectiveProfile['height']) {
        null => null,
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      },
      weight: switch (effectiveProfile['weight']) {
        null => null,
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      },
      goal: normalizeGoal(effectiveProfile['goal']?.toString()),
      createdAt: user['created_at'] != null
          ? DateTime.tryParse(user['created_at'] as String)
          : null,
      updatedAt: effectiveProfile['updated_at'] != null
          ? DateTime.tryParse(effectiveProfile['updated_at'] as String)
          : null,
      // New top-level keys from `GET /profile`; absent/null on old backends.
      assignedAt: _parseAssignedAt(json['assigned_at']),
      workoutPlan: _parseWorkoutPlan(json['workout_plan']),
      nutritionPlan: _parseNutritionPlan(json['nutrition_plan']),
    );
  }

  static DateTime? _parseAssignedAt(Object? value) {
    if (value == null) return null;
    if (value is! String) return null;
    if (value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Returns null for null/missing/non-map values; tolerates partially
  /// missing plan fields with the same empty-default conventions as the
  /// rest of this model. Only the summary fields this endpoint returns are
  /// read — never full plan details.
  static AssignedWorkoutPlanSummary? _parseWorkoutPlan(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return AssignedWorkoutPlanSummary(
      id: value['id']?.toString() ?? '',
      title: value['title']?.toString() ?? '',
      description: value['description']?.toString() ?? '',
      isActive: value['is_active'] as bool? ?? true,
      createdAt: value['created_at'] != null
          ? DateTime.tryParse(value['created_at'].toString())
          : null,
      startDate: value['start_date']?.toString() ?? '',
      cycleDays: (value['cycle_days'] as num?)?.toInt() ?? 0,
    );
  }

  static AssignedNutritionPlanSummary? _parseNutritionPlan(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return AssignedNutritionPlanSummary(
      id: value['id']?.toString() ?? '',
      title: value['title']?.toString() ?? '',
      description: value['description']?.toString() ?? '',
      isActive: value['is_active'] as bool? ?? true,
      createdAt: value['created_at'] != null
          ? DateTime.tryParse(value['created_at'].toString())
          : null,
    );
  }

  CoachProfileEntity toCoachEntity() => CoachProfileEntity(
        id: id,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        location: location,
        profileImage: profileImage,
        bio: bio,
        specialization: specialization,
        specializationDisplay: specializationDisplay,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  ClientProfileEntity toClientEntity() => ClientProfileEntity(
        id: id,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        location: location,
        profileImage: profileImage,
        gender: gender,
        birthDate: birthDate,
        height: height,
        weight: weight,
        goal: goal,
        createdAt: createdAt,
        updatedAt: updatedAt,
        assignedAt: assignedAt,
        workoutPlan: workoutPlan,
        nutritionPlan: nutritionPlan,
      );
}
