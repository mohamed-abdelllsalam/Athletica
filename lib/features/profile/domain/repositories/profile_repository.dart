import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<CoachProfileEntity>> getCoachProfile();
  Future<ApiResult<ClientProfileEntity>> getClientProfile();
  Future<ApiResult<CoachProfileEntity>> updateCoachProfile({
    String? bio,
    String? specialization,
  });
  Future<ApiResult<ClientProfileEntity>> updateClientProfile({
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
  });
  Future<ApiResult<String>> uploadProfileImage(File imageFile);
  Future<ApiResult<void>> deleteProfileImage();
}
