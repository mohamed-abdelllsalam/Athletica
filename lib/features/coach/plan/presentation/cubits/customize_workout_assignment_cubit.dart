import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/usecases/assign_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_plan_exercise_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Per-exercise loads a coach sets for one client assignment. Null means
/// "leave unset" (coach fills it later); the backend treats omitted loads
/// as null. Matched to the created plan by [dayNumber] + [exerciseOrder],
/// which the assign snapshot preserves.
class ExerciseLoadInput {
  const ExerciseLoadInput({
    required this.dayNumber,
    required this.exerciseOrder,
    this.sets,
    this.reps,
    this.restTime,
  });

  final int dayNumber;
  final int exerciseOrder;
  final int? sets;
  final int? reps;
  final int? restTime;

  bool get hasAnyValue => sets != null || reps != null || restTime != null;
}

/// A load resolved to concrete plan ids, ready to PUT.
class PlannedExerciseUpdate {
  const PlannedExerciseUpdate({
    required this.dayId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.restTime,
  });

  final String dayId;
  final String exerciseId;
  final int? sets;
  final int? reps;
  final int? restTime;
}

/// Matches coach inputs to the freshly assigned plan snapshot. Pure so it
/// stays unit-testable without repositories.
List<PlannedExerciseUpdate> matchLoadsToPlan(
  List<PlanDayEntry> days,
  List<ExerciseLoadInput> loads,
) {
  final updates = <PlannedExerciseUpdate>[];
  for (final day in days) {
    for (final exercise in day.exercises) {
      ExerciseLoadInput? input;
      for (final candidate in loads) {
        if (candidate.dayNumber == day.dayNumber &&
            candidate.exerciseOrder == exercise.orderNumber) {
          input = candidate;
          break;
        }
      }
      if (input == null || !input.hasAnyValue) continue;
      updates.add(
        PlannedExerciseUpdate(
          dayId: day.id,
          exerciseId: exercise.id,
          sets: input.sets,
          reps: input.reps,
          restTime: input.restTime,
        ),
      );
    }
  }
  return updates;
}

/// Parses a loads text field: empty = leave unset (null). Pure.
int? parseLoadValue(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

/// A loads field is valid when empty or a positive integer.
bool isValidLoadValue(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return true;
  final value = int.tryParse(trimmed);
  return value != null && value >= 1;
}

sealed class CustomizeAssignmentState {}

final class CustomizeAssignmentInitial extends CustomizeAssignmentState {}

final class CustomizeAssignmentSubmitting extends CustomizeAssignmentState {}

final class CustomizeAssignmentSuccess extends CustomizeAssignmentState {
  CustomizeAssignmentSuccess(this.planId);
  final String planId;
}

final class CustomizeAssignmentFailure extends CustomizeAssignmentState {
  CustomizeAssignmentFailure(this.message);
  final String message;
}

/// Assigns a template to a client and applies per-exercise loads on the
/// created plan snapshot. The template itself is never modified — the
/// server deep-copies it on assign (DOC_6 §4.5).
class CustomizeWorkoutAssignmentCubit
    extends Cubit<CustomizeAssignmentState> {
  CustomizeWorkoutAssignmentCubit(this._assign, this._updateExercise)
      : super(CustomizeAssignmentInitial());

  final AssignWorkoutTemplateUseCase _assign;
  final UpdatePlanExerciseUseCase _updateExercise;

  /// Assigns then applies [loads]. Ignores re-entry while submitting, so
  /// double taps can't create duplicate assignments.
  Future<void> submit({
    required String templateId,
    required String coachClientId,
    required List<ExerciseLoadInput> loads,
  }) async {
    if (state is CustomizeAssignmentSubmitting) return;
    emit(CustomizeAssignmentSubmitting());

    final assigned = await _assign(templateId, coachClientId: coachClientId);
    if (assigned case ApiError(:final failure)) {
      if (isClosed) return;
      emit(CustomizeAssignmentFailure(failure.message));
      return;
    }
    final plan = (assigned as ApiSuccess<WorkoutPlanEntry>).data;

    for (final update in matchLoadsToPlan(plan.days, loads)) {
      final result = await _updateExercise(
        plan.id,
        update.dayId,
        update.exerciseId,
        sets: update.sets,
        reps: update.reps,
        restTime: update.restTime,
      );
      if (result case ApiError(:final failure)) {
        if (isClosed) return;
        // The plan already exists — report honestly instead of
        // pretending nothing was saved.
        emit(
          CustomizeAssignmentFailure(
            'Workout assigned, but some exercise values failed to save: '
            '${failure.message}',
          ),
        );
        return;
      }
    }

    if (isClosed) return;
    emit(CustomizeAssignmentSuccess(plan.id));
  }
}
