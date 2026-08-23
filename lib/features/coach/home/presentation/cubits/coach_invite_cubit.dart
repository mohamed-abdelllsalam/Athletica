import 'package:athletica/core/utils/api_result.dart';
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
    switch (result) {
      case ApiSuccess(:final data):
        final inviteLink = data.inviteUrl.trim();
        if (inviteLink.isEmpty) {
          emit(CoachInviteError('Invite link not available.'));
        } else {
          emit(CoachInviteSuccess(inviteLink));
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
        emit(CoachInviteRevoked());
      case ApiError(:final failure):
        emit(CoachInviteError(failure.message));
    }
  }
}
