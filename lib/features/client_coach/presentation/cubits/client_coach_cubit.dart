import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/features/client_coach/domain/usecases/get_my_coach_usecase.dart';
import 'package:athletica/features/client_coach/domain/usecases/leave_coach_usecase.dart';
import 'package:athletica/features/client_coach/domain/usecases/submit_coach_invite_token_usecase.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientCoachCubit extends Cubit<ClientCoachState> {
  ClientCoachCubit(this._getMyCoach, this._submitToken, this._leaveCoach)
    : super(ClientCoachInitial());

  final GetMyCoachUseCase _getMyCoach;
  final SubmitCoachInviteTokenUseCase _submitToken;
  final LeaveCoachUseCase _leaveCoach;

  Future<void> loadCoach() async {
    if (state is ClientCoachLoading) return;

    final previous = state;
    if (previous is! ClientCoachLoaded) emit(ClientCoachLoading());

    final result = await _getMyCoach();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(
          data == null ? const ClientCoachNoCoach() : ClientCoachLoaded(data),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        if (failure is NetworkFailure && previous is ClientCoachLoaded) {
          emit(ClientCoachLoaded(previous.coach, connectionError: true));
        } else {
          emit(
            ClientCoachError(
              failure.message,
              connectionError: failure is NetworkFailure,
            ),
          );
        }
    }
  }

  Future<void> submitToken(String rawToken) async {
    final token = _normalizeToken(rawToken.trim());
    if (token.isEmpty) {
      emit(const ClientCoachError('Please paste your invite link or token.'));
      return;
    }

    emit(const ClientCoachSubmitting());

    final result = await _submitToken(token);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(ClientCoachRequestSent(data.status, coachName: data.coachName));
        await loadCoach();
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ClientCoachError(failure.message));
    }
  }

  /// Accepts either the raw token or a full invite URL ending in the token.
  String _normalizeToken(String input) {
    if (!input.contains('/')) return input;
    final segments = input
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return segments.isEmpty ? '' : segments.last;
  }

  /// Leaves the current coach. Returns true on success; on failure the
  /// state becomes [ClientCoachError] and false is returned.
  Future<bool> leave() async {
    emit(ClientCoachLoading());

    final result = await _leaveCoach();
    switch (result) {
      case ApiSuccess():
        await loadCoach();
        return true;
      case ApiError(:final failure):
        if (isClosed) return false;
        emit(ClientCoachError(failure.message));
        return false;
    }
  }
}
