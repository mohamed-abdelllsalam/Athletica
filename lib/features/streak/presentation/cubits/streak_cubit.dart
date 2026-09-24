import 'dart:async';
import 'package:athletica/core/usecases/watch_completion_changes_usecase.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:athletica/features/streak/domain/usecases/get_client_streak_usecase.dart';
import 'package:athletica/features/streak/domain/usecases/get_coach_client_streak_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class StreakState {}

final class StreakInitial extends StreakState {}

final class StreakLoading extends StreakState {}

final class StreakLoaded extends StreakState {
  StreakLoaded(this.data);
  final StreakData data;
}

final class StreakEmpty extends StreakState {}

final class StreakError extends StreakState {
  StreakError(this.message);
  final String message;
}

class StreakCubit extends Cubit<StreakState> {
  StreakCubit(
    this._getClientStreak,
    this._getCoachClientStreak, [
    WatchCompletionChangesUseCase? changes,
  ]) : super(StreakInitial()) {
    _subscription = changes?.call().listen((_) => refresh());
  }

  StreamSubscription<void>? _subscription;
  String? _coachClientId;
  bool _hasScope = false;
  int _request = 0;

  Future<void> refresh() async {
    if (!_hasScope || isClosed) return;
    final request = ++_request;
    // Keep the confirmed streak visible while refreshing it. Emitting a
    // loading state here makes the entire streak section flash on every
    // completion change.
    if (state is! StreakLoaded) emit(StreakLoading());
    final result = _coachClientId == null
        ? await _getClientStreak()
        : await _getCoachClientStreak(_coachClientId!);
    if (isClosed || request != _request) return;
    _emitResult(result);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  final GetClientStreakUseCase _getClientStreak;
  final GetCoachClientStreakUseCase _getCoachClientStreak;

  Future<void> loadClient() async {
    _hasScope = true;
    _coachClientId = null;
    await refresh();
  }

  void showEmpty() {
    ++_request;
    emit(StreakEmpty());
  }

  void showError(String message) {
    ++_request;
    emit(StreakError(message));
  }

  Future<void> loadCoachClient(String coachClientId) async {
    if (coachClientId.isEmpty) {
      showError('Client assignment is unavailable.');
      return;
    }
    _hasScope = true;
    _coachClientId = coachClientId;
    await refresh();
  }

  void _emitResult(ApiResult<StreakData> result) {
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final hasData =
            data.workoutSummary != null || data.nutritionSummary != null;
        emit(hasData ? StreakLoaded(data) : StreakEmpty());
      case ApiError(:final failure):
        emit(StreakError(failure.message));
    }
  }
}
