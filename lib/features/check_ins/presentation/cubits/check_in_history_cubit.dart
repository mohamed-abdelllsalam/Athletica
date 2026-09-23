import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submissions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInHistoryCubit extends Cubit<ApiResult<List<CheckInSubmission>>?> {
  CheckInHistoryCubit(this._getSubmissions) : super(null);
  final GetCoachSubmissionsUseCase _getSubmissions;
  int _request = 0;

  Future<void> load(String coachClientId) async {
    final request = ++_request;
    emit(null);
    final result = await _getSubmissions(coachClientId);
    if (!isClosed && request == _request) emit(result);
  }
}
