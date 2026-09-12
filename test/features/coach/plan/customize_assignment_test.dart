import 'package:athletica/features/coach/plan/presentation/cubits/customize_workout_assignment_cubit.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:flutter_test/flutter_test.dart';

PlanDayEntry _day({
  required String id,
  required int dayNumber,
  required List<PlanExerciseEntry> exercises,
}) =>
    PlanDayEntry(
      id: id,
      title: 'Day $dayNumber',
      dayNumber: dayNumber,
      isRest: false,
      exerciseCount: exercises.length,
      exercises: exercises,
    );

const _ex1 = PlanExerciseEntry(id: 'pe-1', exerciseId: '0489', orderNumber: 1);
const _ex2 = PlanExerciseEntry(id: 'pe-2', exerciseId: '0490', orderNumber: 2);

void main() {
  group('matchLoadsToPlan', () {
    test('resolves inputs to plan ids, skipping empty ones', () {
      final updates = matchLoadsToPlan(
        [
          _day(id: 'pd-1', dayNumber: 1, exercises: [_ex1, _ex2]),
          _day(id: 'pd-2', dayNumber: 2, exercises: [_ex1]),
        ],
        const [
          ExerciseLoadInput(dayNumber: 1, exerciseOrder: 1, sets: 4, reps: 10),
          ExerciseLoadInput(dayNumber: 1, exerciseOrder: 2),
          ExerciseLoadInput(dayNumber: 2, exerciseOrder: 1, restTime: 90),
          ExerciseLoadInput(dayNumber: 9, exerciseOrder: 1, sets: 5),
        ],
      );
      expect(updates, hasLength(2));
      expect(updates[0].dayId, 'pd-1');
      expect(updates[0].exerciseId, 'pe-1');
      expect(updates[0].sets, 4);
      expect(updates[0].reps, 10);
      expect(updates[0].restTime, isNull);
      expect(updates[1].dayId, 'pd-2');
      expect(updates[1].restTime, 90);
    });

    test('returns empty when nothing was customized', () {
      expect(matchLoadsToPlan([_day(id: 'pd-1', dayNumber: 1, exercises: [_ex1])], const []), isEmpty);
    });
  });

  group('load value parsing', () {
    test('empty means leave unset', () {
      expect(parseLoadValue(''), isNull);
      expect(parseLoadValue('   '), isNull);
    });

    test('parses positive integers', () {
      expect(parseLoadValue('90'), 90);
    });

    test('validates positivity', () {
      expect(isValidLoadValue(''), isTrue);
      expect(isValidLoadValue('4'), isTrue);
      expect(isValidLoadValue('0'), isFalse);
      expect(isValidLoadValue('-3'), isFalse);
      expect(isValidLoadValue('abc'), isFalse);
    });
  });
}
