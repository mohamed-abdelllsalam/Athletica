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

  static const CoachProfileEntity mock = CoachProfileEntity(
    userId: '1',
    user: TrainerUserEntity(
      id: '1',
      name: 'Mohamed Ahmed',
      phone: '1234567890',
      email: 'mohamed12@gmail.com',
      profileImage: null,
      isVerified: true,
    ),
    profile: TrainerProfileEntity(
      id: '1',
      trainerId: '1',
      bio:
          'Certified fitness coach with 5+ years of experience helping clients '
          'reach their strength and fitness goals through personalized training '
          'and nutrition plans.',
      certifications: 'Certified Personal Trainer (CPT)',
      yearsExperience: 5,
      rating: 4.8,
      isVerified: true,
    ),
  );
}
