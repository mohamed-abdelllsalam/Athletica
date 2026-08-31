import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  const UploadProfileImageUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<String>> call(File imageFile) =>
      _repository.uploadProfileImage(imageFile);
}
