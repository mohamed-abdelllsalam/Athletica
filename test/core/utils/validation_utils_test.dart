import 'package:athletica/core/utils/validation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validatePassword', () {
    test(
      'rejects a password that is too short and has no uppercase letter',
      () {
        expect(
          validatePassword('abcdefg'),
          'Password must be at least 8 characters',
        );
      },
    );

    test(
      'rejects a password without an uppercase letter',
      () {
        expect(
          validatePassword('abcdefgh'),
          'Password must include an uppercase letter',
        );
      },
    );

    test(
      'rejects a password without a lowercase letter',
      () {
        expect(
          validatePassword('ABCDEFGH'),
          'Password must include a lowercase letter',
        );
      },
    );

    test(
      'accepts a password with uppercase and lowercase letters at the minimum length',
      () {
        expect(validatePassword('Abcdefgh'), isNull);
      },
    );

    test('accepts a password containing a number without requiring it', () {
      expect(validatePassword('Abcdefg1'), isNull);
    });

    test(
      'accepts a password containing special characters without requiring them',
      () {
        expect(validatePassword('Abcdef!@'), isNull);
      },
    );

    test(
      'rejects a short password even when it has uppercase and lowercase letters',
      () {
        expect(
          validatePassword('Abc1'),
          'Password must be at least 8 characters',
        );
      },
    );

    test('rejects a null password', () {
      expect(
        validatePassword(null),
        'Password must be at least 8 characters',
      );
    });
  });
}
