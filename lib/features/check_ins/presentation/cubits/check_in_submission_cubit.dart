import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submission_detail_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInSubmissionCubit extends Cubit<ApiResult<CheckInSubmission>?> {
  CheckInSubmissionCubit(this._getCoachDetail, this._getClientDetail)
    : super(null);
  final GetCoachSubmissionDetailUseCase _getCoachDetail;
  final GetClientSubmissionDetailUseCase _getClientDetail;
  int _request = 0;

  Future<void> load({
    String? coachClientId,
    required String submissionId,
  }) async {
    final request = ++_request;
    emit(null);
    final result = coachClientId == null
        ? await _getClientDetail(submissionId)
        : await _getCoachDetail(
            coachClientId: coachClientId,
            submissionId: submissionId,
          );
    if (!isClosed && request == _request) emit(result);
  }
}
