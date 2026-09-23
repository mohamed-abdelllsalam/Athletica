import 'package:athletica/features/check_ins/data/models/check_in_client_status_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> valid() => {
    'has_pending': true,
    'answered': true,
    'submissions_count': 2,
    'last_submitted_at': '2026-09-23T12:05:00Z',
  };

  test('parses documented status and submission timestamp', () {
    final status = CheckInClientStatusModel.fromJson(valid());
    expect(status.hasPending, isTrue);
    expect(status.answered, isTrue);
    expect(status.submissionsCount, 2);
    expect(status.lastSubmittedAt, DateTime.utc(2026, 9, 23, 12, 5));
  });
  test('accepts null timestamp for never-submitted client', () {
    final json = valid()..['last_submitted_at'] = null;
    expect(CheckInClientStatusModel.fromJson(json).lastSubmittedAt, isNull);
  });
  for (final field in ['has_pending', 'answered', 'submissions_count']) {
    test('rejects missing required $field instead of inventing status', () {
      expect(
        () => CheckInClientStatusModel.fromJson(valid()..remove(field)),
        throwsFormatException,
      );
    });
  }
  test('rejects negative submission count', () {
    expect(
      () => CheckInClientStatusModel.fromJson(
        valid()..['submissions_count'] = -1,
      ),
      throwsFormatException,
    );
  });
  test('rejects malformed submission timestamp', () {
    expect(
      () => CheckInClientStatusModel.fromJson(
        valid()..['last_submitted_at'] = 'bad-date',
      ),
      throwsFormatException,
    );
  });
}
