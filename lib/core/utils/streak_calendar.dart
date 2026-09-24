import 'package:athletica/features/streak/domain/entities/streak_data.dart';

/// Calendar-only arithmetic. UTC is a storage container, never converted to local.
DateTime parseCalendarDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw FormatException('Expected YYYY-MM-DD', value);
  }
  final date = DateTime.utc(
    int.parse(value.substring(0, 4)),
    int.parse(value.substring(5, 7)),
    int.parse(value.substring(8, 10)),
  );
  if (calendarDateKey(date) != value) {
    throw FormatException('Invalid date', value);
  }
  return date;
}

String calendarDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class StreakCalendarDay {
  const StreakCalendarDay(this.date, this.status, this.isToday);
  final String date;
  final StreakDayStatus? status;
  final bool isToday;
  String get label => isToday
      ? 'Today'
      : const [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ][parseCalendarDate(date).weekday - 1];
}

/// `to` is today in Africa/Cairo, supplied by the server. The contract describes
/// a rolling seven-day strip, not a locale-dependent calendar week.
List<StreakCalendarDay> buildStreakCalendar({
  required String to,
  required Map<String, StreakDayStatus> statusesByDate,
}) {
  final today = parseCalendarDate(to);
  return List.generate(7, (index) {
    final key = calendarDateKey(today.subtract(Duration(days: 6 - index)));
    return StreakCalendarDay(key, statusesByDate[key], index == 6);
  });
}
