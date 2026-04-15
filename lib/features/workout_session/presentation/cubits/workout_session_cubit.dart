import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/workout_session/domain/entities/set_entry.dart';
import 'package:athletica/features/workout_session/presentation/cubits/workout_session_state.dart';

class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  WorkoutSessionCubit(WorkoutExercise exercise)
      : super(WorkoutSessionState(
          elapsed: Duration.zero,
          sets: List.generate(
            exercise.sets,
            (i) => SetEntry(
              setNumber: i + 1,
              previous: '-',
              target: '-',
              kg: 0,
              reps: 0,
            ),
          ),
        )) {
    _startTimer();
  }

  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1)));
    });
  }

  void updateKg(int index, int kg) {
    final sets = List<SetEntry>.from(state.sets);
    sets[index] = sets[index].copyWith(kg: kg);
    emit(state.copyWith(sets: sets));
  }

  void updateReps(int index, int reps) {
    final sets = List<SetEntry>.from(state.sets);
    sets[index] = sets[index].copyWith(reps: reps);
    emit(state.copyWith(sets: sets));
  }

  void toggleComplete(int index) {
    final sets = List<SetEntry>.from(state.sets);
    sets[index] = sets[index].copyWith(isCompleted: !sets[index].isCompleted);
    emit(state.copyWith(sets: sets));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
