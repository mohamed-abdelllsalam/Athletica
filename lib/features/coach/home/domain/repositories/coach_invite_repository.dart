import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';

abstract class CoachInviteRepository {
  Future<ApiResult<CoachInviteCode>> createInviteCode();
}
