import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.profileImage,
    this.bio = '',
    this.specialization = '',
    this.role,
    this.gender,
    this.birthDate,
    this.height,
    this.weight,
    this.goal,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final String? profileImage;
  final String bio;
  final String specialization;
  final String? role;
  final String? gender;
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return UserProfileModel(
      id: user['id']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      name: user['username']?.toString() ?? '',
      phone: user['phone']?.toString() ?? profile['phone']?.toString() ?? '',
      profileImage: profile['profile_image']?.toString(),
      bio: profile['bio']?.toString() ?? '',
      specialization: profile['specialization']?.toString() ?? '',
      role: user['role']?.toString(),
      gender: profile['gender']?.toString(),
      birthDate: profile['birth_date'] != null
          ? DateTime.tryParse(profile['birth_date'] as String)
          : null,
      height: switch (profile['height']) {
        null => null,
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      },
      weight: switch (profile['weight']) {
        null => null,
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      },
      goal: profile['goal']?.toString(),
      createdAt: user['created_at'] != null
          ? DateTime.tryParse(user['created_at'] as String)
          : null,
      updatedAt: profile['updated_at'] != null
          ? DateTime.tryParse(profile['updated_at'] as String)
          : null,
    );
  }

  CoachProfileEntity toCoachEntity() => CoachProfileEntity(
        id: id,
        email: email,
        name: name,
        phone: phone,
        profileImage: profileImage,
        bio: bio,
        specialization: specialization,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  ClientProfileEntity toClientEntity() => ClientProfileEntity(
        id: id,
        email: email,
        name: name,
        phone: phone,
        profileImage: profileImage,
        gender: gender,
        birthDate: birthDate,
        height: height,
        weight: weight,
        goal: goal,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
