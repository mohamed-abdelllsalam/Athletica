import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';

abstract class CoachProfileRepository {
  Future<ApiResult<CoachProfileEntity>> getCoachProfile(String trainerId);
}
