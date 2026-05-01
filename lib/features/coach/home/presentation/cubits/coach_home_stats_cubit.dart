import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/usecases/get_coach_home_stats_usecase.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_home_stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachHomeStatsCubit extends Cubit<CoachHomeStatsState> {
  CoachHomeStatsCubit(this._getCoachHomeStats) : super(CoachHomeStatsInitial());

  final GetCoachHomeStatsUseCase _getCoachHomeStats;

  Future<void> loadStats() async {
    if (state is CoachHomeStatsLoading) return;

    emit(CoachHomeStatsLoading());

    final trainerId = await TokenStorageService.instance.getTrainerId();
    if (trainerId == null) {
      emit(CoachHomeStatsError('Trainer ID not found. Please log in again.'));
      return;
    }

    final result = await _getCoachHomeStats(trainerId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(CoachHomeStatsLoaded(data));
      case ApiError(:final failure):
        emit(CoachHomeStatsError(failure.message));
    }
  }
}
