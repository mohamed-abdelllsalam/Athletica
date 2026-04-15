import 'package:athletica/features/workout_session/domain/entities/set_entry.dart';

class WorkoutSessionState {
  const WorkoutSessionState({
    required this.elapsed,
    required this.sets,
  });

  final Duration elapsed;
  final List<SetEntry> sets;

  WorkoutSessionState copyWith({
    Duration? elapsed,
    List<SetEntry>? sets,
  }) {
    return WorkoutSessionState(
      elapsed: elapsed ?? this.elapsed,
      sets: sets ?? this.sets,
    );
  }
}
