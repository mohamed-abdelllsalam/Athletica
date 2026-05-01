class TrainerUserEntity {
  const TrainerUserEntity({
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
}

class TrainerProfileEntity {
  const TrainerProfileEntity({
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
}

class CoachProfileEntity {
  const CoachProfileEntity({
    required this.userId,
    required this.user,
    required this.profile,
  });

  final String userId;
  final TrainerUserEntity user;
  final TrainerProfileEntity profile;
}
