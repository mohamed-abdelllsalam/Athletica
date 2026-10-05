class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final bool isVerified;
  final String primaryRole;
  final String? trainerId;
  final String? clientId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    required this.isVerified,
    required this.primaryRole,
    this.trainerId,
    this.clientId,
  });
}

class AuthResponseEntity {
  final String token;
  final String refreshToken;
  final UserEntity user;

  const AuthResponseEntity({
    required this.token,
    required this.refreshToken,
    required this.user,
  });
}
