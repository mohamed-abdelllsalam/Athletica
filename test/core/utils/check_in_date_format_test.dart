import 'package:athletica/core/utils/check_in_date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats afternoon with twelve-hour time', () {
    expect(
      formatCheckInDate(DateTime(2026, 9, 23, 15, 5)),
      '23 Sep 2026, 3:05 PM',
    );
  });
  test('formats midnight as 12 AM', () {
    expect(formatCheckInDate(DateTime(2026, 9, 23)), '23 Sep 2026, 12:00 AM');
  });
  test('formats noon as 12 PM', () {
    expect(
      formatCheckInDate(DateTime(2026, 9, 23, 12)),
      '23 Sep 2026, 12:00 PM',
    );
  });
  test('converts UTC to the same display as device-local time', () {
    final local = DateTime(2026, 9, 23, 15, 5);
    expect(formatCheckInDate(local.toUtc()), '23 Sep 2026, 3:05 PM');
  });
  test('missing timestamp has explicit fallback', () {
    expect(formatCheckInDate(null), 'Time unavailable');
  });
}
