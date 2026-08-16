import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:athletica/features/coach/home/domain/repositories/coach_invite_repository.dart';

class CreateCoachInviteCodeUseCase {
  const CreateCoachInviteCodeUseCase(this._repository);

  final CoachInviteRepository _repository;

  Future<ApiResult<CoachInviteCode>> call() => _repository.createInviteCode();
}
