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
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      primaryRole: json['primaryRole'] as String? ?? '',
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
  final UserModel user;

  const AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(token: token, user: user.toEntity());
  }
}
