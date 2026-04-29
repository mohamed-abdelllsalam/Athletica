import 'package:athletica/features/profile/domain/entities/client_profile_entity.dart';

class ClientModel {
  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        profileImage: json['profileImage'] as String?,
      );

  ClientEntity toEntity() => ClientEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
      );
}

class ClientProfileModel {
  const ClientProfileModel({
    required this.id,
    required this.clientId,
    required this.client,
    this.age,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.medicalConditions,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.dietaryNotes,
    this.updatedAt,
  });

  final String id;
  final String clientId;
  final ClientModel client;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessGoal;
  final String? medicalConditions;
  final int? targetCalories;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;
  final String? dietaryNotes;
  final DateTime? updatedAt;

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) =>
      ClientProfileModel(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
        age: json['age'] as int?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        fitnessGoal: json['fitnessGoal'] as String?,
        medicalConditions: json['medicalConditions'] as String?,
        targetCalories: json['targetCalories'] as int?,
        targetProtein: (json['targetProtein'] as num?)?.toDouble(),
        targetCarbs: (json['targetCarbs'] as num?)?.toDouble(),
        targetFat: (json['targetFat'] as num?)?.toDouble(),
        dietaryNotes: json['dietaryNotes'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );

  ClientProfileEntity toEntity() => ClientProfileEntity(
        id: id,
        clientId: clientId,
        client: client.toEntity(),
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        fitnessGoal: fitnessGoal,
        medicalConditions: medicalConditions,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        dietaryNotes: dietaryNotes,
        updatedAt: updatedAt,
      );
}