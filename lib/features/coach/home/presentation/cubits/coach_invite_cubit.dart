import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:athletica/features/coach/home/domain/usecases/create_coach_invite_code_usecase.dart';
import 'package:athletica/features/coach/home/domain/usecases/revoke_coach_invite_usecase.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_invite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachInviteCubit extends Cubit<CoachInviteState> {
  CoachInviteCubit(this._createInviteCode, this._revokeInvite)
      : super(CoachInviteInitial());

  final CreateCoachInviteCodeUseCase _createInviteCode;
  final RevokeCoachInviteUseCase _revokeInvite;

  Future<void> createInviteLink() async {
    if (state is CoachInviteLoading) return;

    emit(CoachInviteLoading());

    final result = await _createInviteCode();
    if (isClosed) return;
    _emitCreateResult(result);
  }

  /// Revokes the active code (if any) then generates a fresh one. Revoke is
  /// best-effort: when no code is active the backend answers 404
  /// (`no_active_invite`) and creation still proceeds. A fresh code is only
  /// guaranteed when the backend confirms the revoke or none existed.
  Future<void> regenerateInviteLink() async {
    if (state is CoachInviteLoading) return;

    emit(CoachInviteLoading());

    await _revokeInvite();

    final result = await _createInviteCode();
    if (isClosed) return;
    _emitCreateResult(result);
  }

  void _emitCreateResult(ApiResult<CoachInviteCode> result) {
    switch (result) {
      case ApiSuccess(:final data):
        final hasCode = data.code.trim().isNotEmpty;
        final inviteLink = data.inviteUrl.trim();
        if (!hasCode && inviteLink.isEmpty) {
          emit(CoachInviteError('Invite code not available.'));
        } else {
          emit(CoachInviteSuccess(data));
        }
      case ApiError(:final failure):
        emit(CoachInviteError(failure.message));
    }
  }

  Future<void> revokeInviteLink() async {
    if (state is CoachInviteLoading) return;

    emit(CoachInviteLoading());

    final result = await _revokeInvite();
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(CoachInviteRevoked());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachInviteError(failure.message));
    }
  }
}
