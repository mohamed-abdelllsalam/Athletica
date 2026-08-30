import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/usecases/accept_coach_join_request_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_join_requests_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/reject_coach_join_request_usecase.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachJoinRequestsCubit extends Cubit<CoachJoinRequestsState> {
  CoachJoinRequestsCubit(
    this._getRequests,
    this._acceptRequest,
    this._rejectRequest,
  ) : super(CoachJoinRequestsInitial());

  final GetCoachJoinRequestsUseCase _getRequests;
  final AcceptCoachJoinRequestUseCase _acceptRequest;
  final RejectCoachJoinRequestUseCase _rejectRequest;

  Future<void> loadRequests() async {
    if (state is CoachJoinRequestsLoading) return;

    emit(CoachJoinRequestsLoading());

    final result = await _getRequests();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(CoachJoinRequestsLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachJoinRequestsError(failure.message));
    }
  }

  Future<void> accept(String requestId) =>
      _act(requestId, (id) => _acceptRequest(id));

  Future<void> reject(String requestId) =>
      _act(requestId, (id) => _rejectRequest(id));

  Future<void> _act(
    String requestId,
    Future<ApiResult<void>> Function(String) action,
  ) async {
    final requests = state.requests;
    if (state is CoachJoinRequestsActionInProgress) return;

    emit(CoachJoinRequestsActionInProgress(requests, requestId));

    final result = await action(requestId);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(
          CoachJoinRequestsLoaded(
            requests.where((r) => r.id != requestId).toList(),
          ),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachJoinRequestsActionError(requests, failure.message));
    }
  }
}
