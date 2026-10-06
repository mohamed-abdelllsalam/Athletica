import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/usecases/get_coach_home_stats_usecase.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_home_stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachHomeStatsCubit extends Cubit<CoachHomeStatsState> {
  CoachHomeStatsCubit(this._getCoachHomeStats) : super(CoachHomeStatsInitial());

  final GetCoachHomeStatsUseCase _getCoachHomeStats;

  bool _loading = false;

  Future<void> loadStats() async {
    if (_loading || isClosed) return;
    _loading = true;
    final current = state;

    if (current is! CoachHomeStatsLoaded) emit(CoachHomeStatsLoading());

    final result = await _getCoachHomeStats();
    _loading = false;
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(CoachHomeStatsLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          failure is NetworkFailure && current is CoachHomeStatsLoaded
              ? CoachHomeStatsLoaded(current.stats, isConnectionError: true)
              : CoachHomeStatsError(
                  failure.message,
                  isConnectionError: failure is NetworkFailure,
                ),
        );
    }
  }
}
