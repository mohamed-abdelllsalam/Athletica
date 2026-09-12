import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';
import 'package:athletica/features/workout/domain/usecases/complete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_today_workout_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/uncomplete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutTodayCubit completion confirmation', () {
    late _FakeWorkoutRepository repository;
    late WorkoutTodayCubit sut;

    setUp(() {
      repository = _FakeWorkoutRepository();
      sut = WorkoutTodayCubit(
        GetTodayWorkoutUseCase(repository),
        CompleteWorkoutExerciseUseCase(repository),
        UncompleteWorkoutExerciseUseCase(repository),
      );
    });

    tearDown(() => sut.close());

    test('does not confirm celebration when a non-final exercise completes',
        () async {
      repository.todayResult = ApiSuccess(_workout());
      repository.completeResult = const ApiSuccess(
        ExerciseCompletionResult(
          logId: 'log-1',
          completed: true,
          dayCompleted: false,
        ),
      );

      await sut.load();
      await sut.toggle('log-1', true);

      final state = sut.state as WorkoutTodayLoaded;
      expect(state.workout!.dayCompleted, isFalse);
      expect(state.dayCompletionConfirmed, isFalse);
    });

    test('confirms celebration once after final completion succeeds', () async {
      repository.todayResult = ApiSuccess(_workout(secondCompleted: true));
      repository.completeResult = const ApiSuccess(
        ExerciseCompletionResult(
          logId: 'log-1',
          completed: true,
          dayCompleted: true,
        ),
      );

      await sut.load();
      final emitted = <WorkoutTodayState>[];
      final subscription = sut.stream.listen(emitted.add);
      await sut.toggle('log-1', true);
      await subscription.cancel();

      final state = sut.state as WorkoutTodayLoaded;
      expect(state.workout!.dayCompleted, isTrue);
      expect(state.dayCompletionConfirmed, isTrue);
      expect(
        emitted
            .whereType<WorkoutTodayLoaded>()
            .where((state) => state.dayCompletionConfirmed),
        hasLength(1),
      );
    });

    test('does not confirm celebration when an already-complete day reloads',
        () async {
      repository.todayResult = ApiSuccess(
        _workout(firstCompleted: true, secondCompleted: true),
      );

      await sut.load();

      final state = sut.state as WorkoutTodayLoaded;
      expect(state.workout!.dayCompleted, isTrue);
      expect(state.dayCompletionConfirmed, isFalse);
    });

    test('does not confirm celebration for a duplicate completion response',
        () async {
      repository.todayResult = ApiSuccess(
        _workout(firstCompleted: true, secondCompleted: true),
      );
      repository.completeResult = const ApiSuccess(
        ExerciseCompletionResult(
          logId: 'log-1',
          completed: true,
          dayCompleted: true,
        ),
      );

      await sut.load();
      await sut.toggle('log-1', true);

      expect(
        (sut.state as WorkoutTodayLoaded).dayCompletionConfirmed,
        isFalse,
      );
    });

    test('rolls back and does not confirm celebration when completion fails',
        () async {
      repository.todayResult = ApiSuccess(_workout(secondCompleted: true));
      repository.completeResult = const ApiError(
        ServerFailure('Could not complete exercise'),
      );

      await sut.load();
      await sut.toggle('log-1', true);

      final state = sut.state as WorkoutTodayLoaded;
      expect(state.workout!.exercises.first.completed, isFalse);
      expect(state.workout!.dayCompleted, isFalse);
      expect(state.errorMessage, 'Could not complete exercise');
      expect(state.dayCompletionConfirmed, isFalse);
    });
  });
}

TodayWorkoutEntry _workout({
  bool firstCompleted = false,
  bool secondCompleted = false,
}) =>
    TodayWorkoutEntry(
      dayId: 'day-1',
      title: 'Pull',
      dayNumber: 2,
      isRest: false,
      exercises: [
        _exercise('log-1', 1, firstCompleted),
        _exercise('log-2', 2, secondCompleted),
      ],
      dayCompleted: firstCompleted && secondCompleted,
    );

TodayExerciseEntry _exercise(String logId, int order, bool completed) =>
    TodayExerciseEntry(
      logId: logId,
      completed: completed,
      id: 'plan-$order',
      exerciseId: 'exercise-$order',
      orderNumber: order,
    );

class _FakeWorkoutRepository implements WorkoutRepository {
  ApiResult<TodayWorkoutEntry?> todayResult = const ApiSuccess(null);
  ApiResult<ExerciseCompletionResult> completeResult = const ApiError(
    ServerFailure('Complete result not configured'),
  );
  ApiResult<ExerciseCompletionResult> uncompleteResult = const ApiError(
    ServerFailure('Uncomplete result not configured'),
  );

  @override
  Future<ApiResult<TodayWorkoutEntry?>> getTodayWorkout() async => todayResult;

  @override
  Future<ApiResult<ExerciseCompletionResult>> completeExercise(
    String logId,
  ) async =>
      completeResult;

  @override
  Future<ApiResult<ExerciseCompletionResult>> uncompleteExercise(
    String logId,
  ) async =>
      uncompleteResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
