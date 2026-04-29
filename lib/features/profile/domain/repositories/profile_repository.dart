import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/client_profile_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<ClientProfileEntity>> getClientProfile();
}