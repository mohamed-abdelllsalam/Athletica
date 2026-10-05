import 'package:athletica/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final bool isVerified;
  final String primaryRole;
  final String? trainerId;
  final String? clientId;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? '';
    return UserModel(
      id: json['id'] as String,
      name: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      isVerified: json['email_verified'] as bool? ?? false,
      primaryRole: role == 'coach'
          ? 'TRAINER'
          : role == 'client'
          ? 'CLIENT'
          : role,
      trainerId: json['trainerId'] as String?,
      clientId: json['clientId'] as String?,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      profileImage: profileImage,
      isVerified: isVerified,
      primaryRole: primaryRole,
      trainerId: trainerId,
      clientId: clientId,
    );
  }
}

class AuthResponseModel {
  final String token;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      token: token,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }
}
