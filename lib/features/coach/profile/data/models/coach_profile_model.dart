import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';

class TrainerUserModel {
  const TrainerUserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final bool isVerified;

  factory TrainerUserModel.fromJson(Map<String, dynamic> json) =>
      TrainerUserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        profileImage: json['profileImage'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
      );

  TrainerUserEntity toEntity() => TrainerUserEntity(
        id: id,
        name: name,
        phone: phone,
        email: email,
        profileImage: profileImage,
        isVerified: isVerified,
      );
}

class TrainerProfileModel {
  const TrainerProfileModel({
    required this.id,
    required this.trainerId,
    required this.bio,
    required this.certifications,
    required this.yearsExperience,
    required this.rating,
    required this.isVerified,
  });

  final String id;
  final String trainerId;
  final String bio;
  final String certifications;
  final int yearsExperience;
  final double rating;
  final bool isVerified;

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) =>
      TrainerProfileModel(
        id: json['id'] as String,
        trainerId: json['trainerId'] as String,
        bio: json['bio'] as String? ?? '',
        certifications: json['certifications'] as String? ?? '',
        yearsExperience: json['yearsExperience'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        isVerified: json['isVerified'] as bool? ?? false,
      );

  TrainerProfileEntity toEntity() => TrainerProfileEntity(
        id: id,
        trainerId: trainerId,
        bio: bio,
        certifications: certifications,
        yearsExperience: yearsExperience,
        rating: rating,
        isVerified: isVerified,
      );
}

class CoachProfileModel {
  const CoachProfileModel({
    required this.userId,
    required this.user,
    required this.profile,
  });

  final String userId;
  final TrainerUserModel user;
  final TrainerProfileModel profile;

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) =>
      CoachProfileModel(
        userId: json['userId'] as String,
        user: TrainerUserModel.fromJson(json['user'] as Map<String, dynamic>),
        profile: TrainerProfileModel.fromJson(
          json['profile'] as Map<String, dynamic>,
        ),
      );

  CoachProfileEntity toEntity() => CoachProfileEntity(
        userId: userId,
        user: user.toEntity(),
        profile: profile.toEntity(),
      );
}
