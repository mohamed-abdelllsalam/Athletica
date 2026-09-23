import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckInClientStatus', () {
    test('new assignment is pending', () {
      const status = CheckInClientStatus(
        hasPending: true,
        answered: false,
        submissionsCount: 0,
      );
      expect(status.status, CheckInStatus.pending);
    });
    test('answered assignment is completed', () {
      const status = CheckInClientStatus(
        hasPending: false,
        answered: true,
        submissionsCount: 1,
      );
      expect(status.status, CheckInStatus.completed);
    });
    test('reassignment takes priority over past answers', () {
      const status = CheckInClientStatus(
        hasPending: true,
        answered: true,
        submissionsCount: 3,
      );
      expect(status.status, CheckInStatus.pending);
    });
    test('client without assignment or answers is not assigned', () {
      const status = CheckInClientStatus(
        hasPending: false,
        answered: false,
        submissionsCount: 0,
      );
      expect(status.status, CheckInStatus.notAssigned);
    });
  });
}
