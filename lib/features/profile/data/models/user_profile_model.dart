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
      goal: effectiveProfile['goal']?.toString(),
      createdAt: user['created_at'] != null
          ? DateTime.tryParse(user['created_at'] as String)
          : null,
      updatedAt: effectiveProfile['updated_at'] != null
          ? DateTime.tryParse(effectiveProfile['updated_at'] as String)
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
      );
}
