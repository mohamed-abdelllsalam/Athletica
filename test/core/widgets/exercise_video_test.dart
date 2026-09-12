import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveExerciseVideoUrl', () {
    const male = 'https://cdn.example/male.mp4';
    const female = 'https://cdn.example/female.mp4';

    test('plays the female version for female profiles', () {
      for (final gender in ['female', 'Female', 'FEMALE', ' f ']) {
        expect(
          resolveExerciseVideoUrl(
            maleUrl: male,
            femaleUrl: female,
            gender: gender,
          ),
          female,
        );
      }
    });

    test('falls back to male for anything else', () {
      for (final gender in [null, '', 'male', 'Male', 'other']) {
        expect(
          resolveExerciseVideoUrl(
            maleUrl: male,
            femaleUrl: female,
            gender: gender,
          ),
          male,
        );
      }
    });

    test('uses whichever version exists when one is missing', () {
      expect(
        resolveExerciseVideoUrl(maleUrl: '', femaleUrl: female, gender: 'f'),
        female,
      );
      expect(
        resolveExerciseVideoUrl(maleUrl: male, femaleUrl: '', gender: 'male'),
        male,
      );
      expect(
        resolveExerciseVideoUrl(maleUrl: '', femaleUrl: '', gender: 'female'),
        isEmpty,
      );
    });
  });

  group('pickGenderedUrl', () {
    test('picks the gender-matched thumbnail', () {
      expect(
        pickGenderedUrl(
          maleUrl: 'https://cdn.example/m.jpg',
          femaleUrl: 'https://cdn.example/f.jpg',
          gender: 'Female',
        ),
        'https://cdn.example/f.jpg',
      );
      expect(
        pickGenderedUrl(
          maleUrl: 'https://cdn.example/m.jpg',
          femaleUrl: 'https://cdn.example/f.jpg',
        ),
        'https://cdn.example/m.jpg',
      );
    });
  });
}
