import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/save_workout_plan_state.dart';
import 'package:athletica/features/workout/domain/usecases/add_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/create_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/create_workout_template_v1_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_template_day_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Persists a plan built in the create-mode editor:
/// 1. POST /workout/templates            (title + description)
/// 2. POST /workout/templates/:id/days   (one call per day, in order)
/// 3. PATCH .../days/:dayId              (mark rest days)
/// 4. POST .../days/:dayId/exercises     (per exercise, in order; skipped for rest)
class SaveWorkoutPlanCubit extends Cubit<SaveWorkoutPlanState> {
  SaveWorkoutPlanCubit(
    this._createTemplate,
    this._createDay,
    this._addExercise,
    this._updateDay,
  ) : super(SaveWorkoutPlanIdle());

  final CreateWorkoutTemplateV1UseCase _createTemplate;
  final CreateTemplateDayUseCase _createDay;
  final AddTemplateExerciseUseCase _addExercise;
  final UpdateTemplateDayUseCase _updateDay;

  Future<void> savePlan(WorkoutProgram program) async {
    if (state is SaveWorkoutPlanLoading) return;
    emit(SaveWorkoutPlanLoading());

    // 1. Create the template
    final templateResult = await _createTemplate(
      title: program.name.trim(),
      description: program.description.trim(),
    );

    switch (templateResult) {
      case ApiError(:final failure):
        if (isClosed) return;
        emit(SaveWorkoutPlanError(failure.message));
        return;
      case ApiSuccess(:final data):
        var template = data;
        // 2. Create each day in order
        for (final day in program.days) {
          final previousIds = template.days.map((d) => d.id).toSet();
          final dayResult = await _createDay(
            template.id,
            title: day.name.trim().isEmpty
                ? 'Day ${day.dayNumber}'
                : day.name.trim(),
            note: day.note.trim().isEmpty ? null : day.note.trim(),
          );
          if (isClosed) return;
          switch (dayResult) {
            case ApiError(:final failure):
              emit(SaveWorkoutPlanError(_partialMessage(failure.message)));
              return;
            case ApiSuccess(:final data):
              template = data;
          }
          final added = template.days
              .where((d) => !previousIds.contains(d.id))
              .toList();
          if (added.length != 1) {
            emit(
              SaveWorkoutPlanError(
                _partialMessage(
                  'Could not identify the saved day. Please reload your plans before trying again.',
                ),
              ),
            );
            return;
          }
          final dayId = added.single.id;
          // 3. Mark rest days — created days default to training days.
          if (day.isRest) {
            final restResult = await _updateDay(
              template.id,
              dayId,
              isRest: true,
            );
            if (isClosed) return;
            switch (restResult) {
              case ApiError(:final failure):
                emit(SaveWorkoutPlanError(_partialMessage(failure.message)));
                return;
              case ApiSuccess(:final data):
                template = data;
            }
            continue;
          }
          // 4. Add exercises to this day — catalog ids are opaque strings
          // (e.g. "0489"), never UUID-validated (DOC_6 §1.2).
          for (var i = 0; i < day.exercises.length; i++) {
            final exercise = day.exercises[i];
            if (exercise.id.isEmpty) continue;
            final exerciseResult = await _addExercise(
              template.id,
              dayId,
              exerciseId: exercise.id,
              exerciseOrder: i + 1,
            );
            if (isClosed) return;
            switch (exerciseResult) {
              case ApiError(:final failure):
                emit(SaveWorkoutPlanError(_partialMessage(failure.message)));
                return;
              case ApiSuccess(:final data):
                template = data;
            }
          }
        }
        if (isClosed) return;
        emit(SaveWorkoutPlanSuccess());
    }
  }

  /// The template (and any earlier days/exercises) already exists
  /// server-side when a day/exercise write fails — there is no
  /// transactional endpoint — so the message must say so instead of
  /// implying nothing was saved. Retrying creates a new template; the
  /// coach should check the library first to avoid duplicates.
  static String _partialMessage(String serverMessage) =>
      '$serverMessage The workout plan was partially saved — check your library before trying again.';
}
