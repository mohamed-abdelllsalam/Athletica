import 'package:athletica/features/workout/data/models/today_workout_model.dart';
import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/data/models/workout_plan_model.dart';
import 'package:athletica/features/workout/data/models/workout_template_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutExerciseModel', () {
    test('parses all documented fields with nullable-safe defaults', () {
      const json = {
        'id': 'ex-1',
        'name_en': 'Bench Press',
        'name_ar': 'بنش برس',
        'primary_muscle': 'chest',
        'secondary_muscles': ['triceps'],
        'equipment': 'barbell',
        'difficulty': 'intermediate',
        'exercise_type': 'strength',
        'classification': ['compound'],
        'movement_pattern': 'push',
        'fitness_goals': ['muscle_gain'],
        'workout_location': 'gym',
        'media_type': 'video',
        'media_url': 'https://x/media',
        'video_url': 'https://x/video',
        'tags': ['push'],
        'is_default': true,
        'priority': 'high',
      };
      final model = WorkoutExerciseModel.fromJson(json);
      expect(model.id, 'ex-1');
      expect(model.localizedName(false), 'Bench Press');
      expect(model.localizedName(true), 'بنش برس');
      expect(model.secondaryMuscles, ['triceps']);
      expect(model.isDefault, isTrue);
    });

    test('falls back to English when Arabic name is empty', () {
      final model = WorkoutExerciseModel.fromJson({
        'id': 'ex-2',
        'name_en': 'Squat',
        'name_ar': '',
      });
      expect(model.localizedName(true), 'Squat');
    });
  });

  group('WorkoutTemplateModel', () {
    test('uses exercise_order and keeps template sets/reps null', () {
      final model = WorkoutTemplateModel.fromResponse({
        'success': true,
        'data': {
          'id': 'tid',
          'title': 'PPL',
          'description': 'split',
          'coach_id': 'coach-1',
          'day_count': 1,
          'days': [
            {
              'id': 'did',
              'title': 'Push',
              'day_number': 1,
              'is_rest': false,
              'exercise_count': 1,
              'exercises': [
                {
                  'id': 'teid',
                  'exercise_id': 'ex-1',
                  'exercise_order': 1,
                  'sets': null,
                  'reps': null,
                  'notes': '',
                  'exercise': {'id': 'ex-1', 'name_en': 'Bench Press'},
                },
              ],
            },
          ],
        },
      });
      expect(model.id, 'tid');
      expect(model.days, hasLength(1));
      final ex = model.days.single.exercises.single;
      expect(ex.exerciseOrder, 1);
      expect(ex.sets, isNull);
      expect(ex.reps, isNull);
      // Embedded exercise object — no second fetch needed.
      expect(ex.exercise?.nameEn, 'Bench Press');
    });
  });

  group('WorkoutPlanModel', () {
    test('uses order_number and parses start_date/cycle_days', () {
      final model = WorkoutPlanModel.fromResponse({
        'success': true,
        'data': {
          'id': 'pid',
          'coach_id': 'coach-1',
          'coach_client_id': 'cc-1',
          'title': 'January',
          'description': 'plan',
          'start_date': '2026-09-09',
          'cycle_days': 3,
          'is_active': true,
          'day_count': 1,
          'days': [
            {
              'id': 'pdid',
              'title': 'Pull',
              'day_number': 2,
              'is_rest': false,
              'exercise_count': 1,
              'exercises': [
                {
                  'id': 'peid',
                  'exercise_id': 'ex-9',
                  'order_number': 1,
                  'sets': 4,
                  'reps': 10,
                  'notes': '',
                  'exercise': {'id': 'ex-9', 'name_en': 'Pull Up'},
                },
              ],
            },
          ],
        },
      });
      expect(model.startDate, '2026-09-09');
      expect(model.cycleDays, 3);
      final ex = model.days.single.exercises.single;
      expect(ex.orderNumber, 1);
      expect(ex.sets, 4);
      expect(ex.reps, 10);
    });
  });

  group('TodayWorkoutModel', () {
    test('returns null workout for {workout: null}', () {
      final model = TodayWorkoutModel.fromResponse({
        'success': true,
        'data': {
          'workout': null,
        },
      });
      expect(model, isNull);
    });

    test('keeps log_id separate from exercise ids', () {
      final model = TodayWorkoutModel.fromResponse({
        'success': true,
        'data': {
          'workout': {
            'day_id': 'day-uuid',
            'title': 'Pull Day',
            'day_number': 2,
            'is_rest': false,
            'exercises': [
              {
                'log_id': 'elog-uuid',
                'completed': false,
                'completed_at': null,
                'id': 'pde-uuid',
                'exercise_id': 'ex-uuid',
                'order_number': 1,
                'sets': 4,
                'reps': 10,
                'notes': '',
                'exercise': {'id': 'ex-uuid', 'name_en': 'Pull Up'},
              },
            ],
            'day_completed': false,
          },
        },
      })!;
      final ex = model.exercises.single;
      expect(ex.logId, 'elog-uuid');
      expect(ex.id, 'pde-uuid');
      expect(ex.exerciseId, 'ex-uuid');
      expect(ex.logId, isNot(ex.id));
      expect(ex.logId, isNot(ex.exerciseId));
      expect(model.dayCompleted, isFalse);
    });

    test('parses rest day shape', () {
      final model = TodayWorkoutModel.fromResponse({
        'success': true,
        'data': {
          'workout': {
            'day_id': 'day-uuid',
            'title': 'Rest',
            'day_number': 3,
            'is_rest': true,
            'exercises': [],
            'day_completed': true,
          },
        },
      })!;
      expect(model.isRest, isTrue);
      expect(model.exercises, isEmpty);
      expect(model.dayCompleted, isTrue);
    });
  });

  group('ExerciseCompletionModel', () {
    test('reads exercise_log + day_completed', () {
      final model = ExerciseCompletionModel.fromResponse({
        'success': true,
        'data': {
          'exercise_log': {
            'log_id': 'elog-uuid',
            'completed': true,
            'completed_at': '2026-09-09T08:30:00Z',
            'order_number': 1,
          },
          'day_completed': true,
        },
      });
      expect(model.logId, 'elog-uuid');
      expect(model.completed, isTrue);
      expect(model.dayCompleted, isTrue);
    });
  });

  group('WorkoutHistoryModel', () {
    test('parses param-less history entries', () {
      final model = WorkoutHistoryModel.fromJson({
        'success': true,
        'data': {
          'history': [
            {
              'date': '2026-09-09',
              'day_id': 'day-uuid',
              'day_number': 2,
              'title': 'Pull Day',
              'is_rest': false,
              'total_exercises': 5,
              'completed_exercises': 3,
              'all_completed': false,
            },
            {
              'date': '2026-09-07',
              'day_id': 'day-uuid',
              'day_number': 1,
              'title': 'Rest',
              'is_rest': true,
              'total_exercises': 0,
              'completed_exercises': 0,
              'all_completed': true,
            },
          ],
        },
      });
      expect(model.days, hasLength(2));
      expect(model.days.first.allCompleted, isFalse);
      expect(model.days.first.isMissed('2026-09-10'), isTrue);
      expect(model.days.last.isCompletedUi, isTrue);
    });
  });
}
