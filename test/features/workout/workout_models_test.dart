import 'package:athletica/features/workout/data/models/today_workout_model.dart';
import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/data/models/workout_plan_model.dart';
import 'package:athletica/features/workout/data/models/workout_template_model.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
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

  group('WorkoutTemplateModel exerciseCount', () {
    test('reads template-level exercise_count without embedded days', () {
      // Shape sent by the templates list API.
      final model = WorkoutTemplateModel.fromResponse({
        'success': true,
        'data': {
          'id': '43c4a20b-fdbd-4f56-8719-87eb72dd3d7e',
          'title': 'gg',
          'description': 'gg',
          'coach_id': 'd22af68f-049d-4644-975f-4eec390313e1',
          'day_count': 2,
          'exercise_count': 3,
          'created_at': '2026-09-12T12:16:47.583Z',
        },
      });
      expect(model.dayCount, 2);
      expect(model.exerciseCount, 3);
      expect(model.days, isEmpty);
    });

    test('sums per-day counts when the template key is absent', () {
      final model = WorkoutTemplateModel.fromResponse({
        'success': true,
        'data': {
          'id': 'tid',
          'title': 'PPL',
          'description': 'split',
          'coach_id': 'coach-1',
          'day_count': 2,
          'days': [
            {
              'id': 'd1',
              'title': 'Push',
              'day_number': 1,
              'is_rest': false,
              'exercise_count': 4,
              'exercises': [],
            },
            {
              'id': 'd2',
              'title': 'Pull',
              'day_number': 2,
              'is_rest': false,
              'exercises': [
                {'id': 'e1', 'exercise_id': 'ex-1', 'exercise_order': 1},
              ],
            },
          ],
        },
      });
      expect(model.exerciseCount, 5);
    });
  });

  group('WorkoutExerciseModel new library shape', () {
    test('parses name/target/camelCase muscles without old keys', () {
      final model = WorkoutExerciseModel.fromJson({
        'id': '92844e23-dd84-4936-a37b-49de36ecf868',
        'name': '45 Degree Hyperextension',
        'bodyPart': 'back',
        'target': 'erector spinae',
        'secondaryMuscles': ['glutes', 'hamstrings', 'lower back'],
        'equipment': 'leverage machine',
        'difficulty': 'beginner',
        'muscleGroup': 'erector spinae',
        'compound': true,
        'unilateral': false,
      });
      expect(model.id, '92844e23-dd84-4936-a37b-49de36ecf868');
      expect(model.nameEn, '45 Degree Hyperextension');
      expect(model.nameAr, isEmpty);
      expect(model.primaryMuscle, 'erector spinae');
      expect(model.secondaryMuscles, ['glutes', 'hamstrings', 'lower back']);
      expect(model.equipment, 'leverage machine');
      expect(model.difficulty, 'beginner');
      expect(model.localizedName(false), '45 Degree Hyperextension');
    });

    test('prefers legacy keys when both shapes are present', () {
      final model = WorkoutExerciseModel.fromJson({
        'id': 'ex-1',
        'name': 'New Name',
        'name_en': 'Bench Press',
        'primary_muscle': 'chest',
        'target': 'lats',
      });
      expect(model.nameEn, 'Bench Press');
      expect(model.primaryMuscle, 'chest');
    });

    test('parses demo videos and thumbnails', () {
      final model = WorkoutExerciseModel.fromJson({
        'id': '92844e23-dd84-4936-a37b-49de36ecf868',
        'name': '45 Degree Hyperextension',
        'videos': {
          'male': 'https://cdn.example/male.mp4',
          'female': 'https://cdn.example/female.mp4',
        },
        'thumbnails': {
          'male': 'https://cdn.example/male.jpg',
        },
      });
      expect(model.videoUrlMale, 'https://cdn.example/male.mp4');
      expect(model.videoUrlFemale, 'https://cdn.example/female.mp4');
      expect(model.thumbnailUrlMale, 'https://cdn.example/male.jpg');
      expect(model.thumbnailUrlFemale, isEmpty);
      expect(model.toEntity().videoUrlFemale, 'https://cdn.example/female.mp4');
    });

    test('defaults media to empty when absent', () {
      const model = WorkoutExerciseModel(
        id: 'ex-1',
        nameEn: 'Bench Press',
        nameAr: '',
        primaryMuscle: 'chest',
        secondaryMuscles: [],
        equipment: '',
        difficulty: '',
        exerciseType: '',
        classification: [],
        movementPattern: '',
        fitnessGoals: [],
        workoutLocation: '',
        mediaType: '',
        mediaUrl: '',
        videoUrl: '',
        tags: [],
        isDefault: false,
        priority: '',
      );
      expect(model.videoUrlMale, isEmpty);
      expect(model.videoUrlFemale, isEmpty);
      expect(model.thumbnailUrlMale, isEmpty);
      expect(model.thumbnailUrlFemale, isEmpty);
    });
  });

  group('DOC_6 day note', () {
    test('parses template day note', () {
      final model = WorkoutTemplateModel.fromResponse({
        'success': true,
        'data': {
          'id': 'tid',
          'title': 'PPL',
          'description': 'split',
          'coach_id': 'coach-1',
          'day_count': 1,
          'exercise_count': 0,
          'days': [
            {
              'id': 'd1',
              'title': 'Push',
              'day_number': 1,
              'is_rest': false,
              'note': 'Focus on form',
              'exercise_count': 0,
              'exercises': [],
            },
          ],
        },
      });
      expect(model.days.single.note, 'Focus on form');
    });

    test('defaults template day note to empty when absent', () {
      final model = WorkoutTemplateModel.fromResponse({
        'success': true,
        'data': {
          'id': 'tid',
          'title': 'PPL',
          'description': 'split',
          'coach_id': 'coach-1',
          'days': [
            {'id': 'd1', 'title': 'Push', 'day_number': 1},
          ],
        },
      });
      expect(model.days.single.note, isEmpty);
    });

    test('parses plan day note', () {
      final model = WorkoutPlanModel.fromResponse({
        'success': true,
        'data': {
          'id': 'pid',
          'coach_id': 'coach-1',
          'coach_client_id': 'cc-1',
          'title': 'January',
          'description': 'plan',
          'start_date': '2026-09-09',
          'cycle_days': 1,
          'is_active': true,
          'day_count': 1,
          'days': [
            {
              'id': 'pdid',
              'title': 'Pull',
              'day_number': 1,
              'is_rest': false,
              'note': 'Light week',
              'exercise_count': 0,
              'exercises': [],
            },
          ],
        },
      });
      expect(model.days.single.note, 'Light week');
    });

    test('parses today note', () {
      final model = TodayWorkoutModel.fromResponse({
        'success': true,
        'data': {
          'workout': {
            'day_id': 'day-uuid',
            'title': 'Pull Day',
            'day_number': 2,
            'is_rest': false,
            'note': 'Go heavy',
            'exercises': [],
            'day_completed': false,
          },
        },
      })!;
      expect(model.note, 'Go heavy');
    });
  });

  group('DOC_6 rest_time', () {
    test('parses plan exercise rest_time', () {
      final model = WorkoutPlanModel.fromResponse({
        'success': true,
        'data': {
          'id': 'pid',
          'coach_id': 'coach-1',
          'coach_client_id': 'cc-1',
          'title': 'January',
          'description': 'plan',
          'start_date': '2026-09-09',
          'cycle_days': 1,
          'is_active': true,
          'day_count': 1,
          'days': [
            {
              'id': 'pdid',
              'title': 'Pull',
              'day_number': 1,
              'is_rest': false,
              'exercise_count': 1,
              'exercises': [
                {
                  'id': 'peid',
                  'exercise_id': '0489',
                  'order_number': 1,
                  'sets': 4,
                  'reps': 10,
                  'rest_time': 90,
                  'notes': '',
                },
              ],
            },
          ],
        },
      });
      expect(model.days.single.exercises.single.restTime, 90);
    });

    test('defaults rest_time to null when absent', () {
      final model = WorkoutPlanModel.fromResponse({
        'success': true,
        'data': {
          'id': 'pid',
          'coach_id': 'coach-1',
          'coach_client_id': 'cc-1',
          'title': 't',
          'description': 'd',
          'start_date': '2026-09-09',
          'cycle_days': 1,
          'is_active': true,
          'day_count': 1,
          'days': [
            {
              'id': 'pdid',
              'title': 'Pull',
              'day_number': 1,
              'is_rest': false,
              'exercise_count': 1,
              'exercises': [
                {'id': 'peid', 'exercise_id': '0489', 'order_number': 1},
              ],
            },
          ],
        },
      });
      expect(model.days.single.exercises.single.restTime, isNull);
    });

    test('parses today exercise rest_time', () {
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
                'id': 'pde-uuid',
                'exercise_id': '0489',
                'order_number': 1,
                'sets': 4,
                'reps': 10,
                'rest_time': 60,
                'notes': '',
              },
            ],
            'day_completed': false,
          },
        },
      })!;
      expect(model.exercises.single.restTime, 60);
    });
  });

  group('WorkoutExerciseEntry.matchesQuery', () {
    WorkoutExerciseEntry entry() => WorkoutExerciseModel.fromJson({
          'id': '07076bb5-a9e1-403d-8820-18f966148897',
          'name': 'Band Assisted Pull-up',
          'aliases': ['assisted pull-up', 'band pull-up'],
          'bodyPart': 'back',
          'target': 'lats',
          'secondaryMuscles': ['biceps', 'forearms'],
          'equipment': 'band',
          'difficulty': 'intermediate',
          'muscleGroup': 'biceps',
        }).toEntity();

    test('parses aliases, bodyPart and muscleGroup', () {
      final e = entry();
      expect(e.aliases, contains('band pull-up'));
      expect(e.bodyPart, 'back');
      expect(e.muscleGroup, 'biceps');
    });

    test('matches names, aliases, muscles and equipment', () {
      final e = entry();
      for (final q in [
        'pull-up',
        'PULL-UP',
        'band pull-up',
        'lats',
        'back',
        'biceps',
        'forearms',
        'band',
        'glutes',
      ]) {
        final shouldMatch = q != 'glutes';
        expect(e.matchesQuery(q), shouldMatch, reason: 'query: $q');
      }
    });

    test('blank query matches everything', () {
      expect(entry().matchesQuery('  '), isTrue);
    });
  });
}
