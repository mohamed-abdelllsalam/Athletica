class ClientEntity {
  const ClientEntity({
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
}

class ClientProfileEntity {
  const ClientProfileEntity({
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
  final ClientEntity client;
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
}