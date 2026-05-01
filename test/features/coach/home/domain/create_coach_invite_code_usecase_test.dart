import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:athletica/features/coach/home/domain/repositories/coach_invite_repository.dart';
import 'package:athletica/features/coach/home/domain/usecases/create_coach_invite_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoachInviteRepository implements CoachInviteRepository {
  _FakeCoachInviteRepository(this.result);

  ApiResult<CoachInviteCode> result;

  @override
  Future<ApiResult<CoachInviteCode>> createInviteCode() async => result;
}

void main() {
  test('returns invite code when repository succeeds', () async {
    const inviteCode = CoachInviteCode(
      id: 'invite-1',
      trainerId: 'trainer-1',
      code: 'ATHLICOACH100',
      totalClients: 0,
      inviteLink: 'https://example.com/invite',
    );
    final repository = _FakeCoachInviteRepository(ApiSuccess(inviteCode));
    final useCase = CreateCoachInviteCodeUseCase(repository);

    final result = await useCase();

    expect(result, isA<ApiSuccess<CoachInviteCode>>());
    expect((result as ApiSuccess<CoachInviteCode>).data, inviteCode);
  });

  test('returns failure when repository fails', () async {
    const failure = ServerFailure('Server error');
    final repository = _FakeCoachInviteRepository(ApiError(failure));
    final useCase = CreateCoachInviteCodeUseCase(repository);

    final result = await useCase();

    expect(result, isA<ApiError<CoachInviteCode>>());
    expect((result as ApiError<CoachInviteCode>).failure, failure);
  });
}
