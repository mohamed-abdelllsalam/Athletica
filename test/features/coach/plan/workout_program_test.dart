import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:flutter_test/flutter_test.dart';

ProgramDay _day({List<ProgramExercise> exercises = const [], int? count}) =>
    ProgramDay(
      dayNumber: 1,
      name: 'Day 1',
      durationMinutes: 60,
      exercises: exercises,
      exerciseCount: count,
    );

const _ex = ProgramExercise(id: 'e1', name: 'Bench Press');

void main() {
  group('ProgramDay.exerciseCount', () {
    test('uses the backend count when provided', () {
      // List API may omit embedded exercises but still send exercise_count.
      final day = _day(exercises: const [], count: 5);
      expect(day.exerciseCount, 5);
    });

    test('falls back to the local list length when omitted', () {
      final day = _day(exercises: const [_ex, _ex]);
      expect(day.exerciseCount, 2);
    });

    test('copyWith with new exercises recomputes the count', () {
      final day = _day(exercises: const [], count: 5);
      final edited = day.copyWith(exercises: const [_ex]);
      expect(edited.exerciseCount, 1);
    });

    test('copyWith without exercises preserves the backend count', () {
      final day = _day(exercises: const [_ex], count: 5);
      final renamed = day.copyWith(name: 'Push');
      expect(renamed.exerciseCount, 5);
    });
  });

  group('WorkoutProgram.totalExercises', () {
    test('sums backend counts across days', () {
      final program = WorkoutProgram(
        id: 't1',
        name: 'PPL',
        category: 'Custom',
        splitType: '3 Days Split',
        updatedAgo: 'Just now',
        clientCount: 0,
        description: '',
        iconAsset: '',
        days: [
          _day(exercises: const [], count: 4),
          _day(exercises: const [_ex], count: 3),
        ],
      );
      expect(program.totalExercises, 7);
    });

    test('prefers the template-level backend count when provided', () {
      // List API shape: counts without embedded days.
      final program = WorkoutProgram(
        id: 't1',
        name: 'gg',
        category: 'Custom',
        splitType: '2 Days Split',
        updatedAgo: 'Just now',
        clientCount: 0,
        description: 'gg',
        iconAsset: '',
        totalExercises: 3,
        days: const [],
      );
      expect(program.totalExercises, 3);
    });

    test('falls back to the day sum when omitted', () {
      final program = WorkoutProgram(
        id: 't1',
        name: 'PPL',
        category: 'Custom',
        splitType: '1 Days Split',
        updatedAgo: 'Just now',
        clientCount: 0,
        description: '',
        iconAsset: '',
        days: [
          _day(exercises: const [_ex, _ex]),
        ],
      );
      expect(program.totalExercises, 2);
    });
  });

  group('ProgramExercise media', () {
    test('defaults video urls to empty', () {
      expect(_ex.videoUrlMale, isEmpty);
      expect(_ex.videoUrlFemale, isEmpty);
    });

    test('carries backend video urls', () {
      const ex = ProgramExercise(
        id: 'e1',
        name: 'Row',
        videoUrlMale: 'https://cdn.example/m.mp4',
        videoUrlFemale: 'https://cdn.example/f.mp4',
      );
      expect(ex.videoUrlMale, 'https://cdn.example/m.mp4');
      expect(ex.videoUrlFemale, 'https://cdn.example/f.mp4');
    });
  });

  group('Pick types carry demo media', () {
    test('LibraryExercise defaults media to empty', () {
      const lib = LibraryExercise(id: 'e1', name: 'Row', muscleGroup: 'back');
      expect(lib.thumbnailUrl, isEmpty);
      expect(lib.videoUrlMale, isEmpty);
      expect(lib.videoUrlFemale, isEmpty);
    });

    test('LibraryExercise carries backend media', () {
      const lib = LibraryExercise(
        id: 'e1',
        name: 'Row',
        muscleGroup: 'back',
        thumbnailUrl: 'https://cdn.example/m.jpg',
        videoUrlMale: 'https://cdn.example/m.mp4',
        videoUrlFemale: 'https://cdn.example/f.mp4',
      );
      expect(lib.thumbnailUrl, 'https://cdn.example/m.jpg');
      expect(lib.videoUrlMale, 'https://cdn.example/m.mp4');
      expect(lib.videoUrlFemale, 'https://cdn.example/f.mp4');
    });
  });
}
