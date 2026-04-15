import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athletica/features/workout_session/presentation/cubits/rest_timer_state.dart';

class RestTimerCubit extends Cubit<RestTimerState> {
  static const _defaultDuration = Duration(seconds: 15);

  RestTimerCubit()
      : super(const RestTimerRunning(
          remaining: _defaultDuration,
          total: _defaultDuration,
        )) {
    _startTick();
  }

  Timer? _timer;

  void _startTick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is! RestTimerRunning) return;
      final next = state.remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _timer?.cancel();
        emit(RestTimerDone(total: state.total));
      } else {
        emit(RestTimerRunning(remaining: next, total: state.total));
      }
    });
  }

  void togglePause() {
    if (state is RestTimerRunning) {
      _timer?.cancel();
      emit(RestTimerPaused(remaining: state.remaining, total: state.total));
    } else if (state is RestTimerPaused) {
      emit(RestTimerRunning(remaining: state.remaining, total: state.total));
      _startTick();
    }
  }

  void skip() {
    _timer?.cancel();
    emit(RestTimerDone(total: state.total));
  }

  void adjustSeconds(int delta) {
    if (state is RestTimerDone) return;
    final newRemaining = state.remaining + Duration(seconds: delta);
    final newTotal = state.total + Duration(seconds: delta);
    if (newRemaining <= Duration.zero) {
      skip();
      return;
    }
    if (state is RestTimerRunning) {
      emit(RestTimerRunning(remaining: newRemaining, total: newTotal));
    } else {
      emit(RestTimerPaused(remaining: newRemaining, total: newTotal));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
