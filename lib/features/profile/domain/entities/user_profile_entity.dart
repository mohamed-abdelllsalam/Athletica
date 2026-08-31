class CoachProfileEntity {
  const CoachProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImage,
    this.bio = '',
    this.specialization = '',
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CoachProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? bio,
    String? specialization,
  }) =>
      CoachProfileEntity(
        id: id,
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        profileImage: profileImage ?? this.profileImage,
        bio: bio ?? this.bio,
        specialization: specialization ?? this.specialization,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class ClientProfileEntity {
  const ClientProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImage,
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
  final String? gender;
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
  }) =>
      ClientProfileEntity(
        id: id,
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        profileImage: profileImage ?? this.profileImage,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        goal: goal ?? this.goal,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
