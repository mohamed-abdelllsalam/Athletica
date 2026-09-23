import 'package:intl/intl.dart';

String formatChatDay(DateTime date, {DateTime? now}) {
  final localDate = date.toLocal();
  final today = now ?? DateTime.now();
  final localToday = DateTime(today.year, today.month, today.day);
  final messageDay = DateTime(localDate.year, localDate.month, localDate.day);
  final difference = localToday.difference(messageDay).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return DateFormat('d MMM yyyy', 'en_US').format(localDate);
}

String formatChatTime(DateTime date) =>
    DateFormat('h:mm a', 'en_US').format(date.toLocal());

String formatChatDayText(String value) {
  final date = DateTime.tryParse(value);
  if (date != null) return formatChatDay(date);
  if (value.startsWith('Today')) return 'Today';
  if (value.startsWith('Yesterday')) return 'Yesterday';
  return value;
}

String formatChatTimeText(String value) {
  if (value.trim().toLowerCase() == 'now') {
    return formatChatTime(DateTime.now());
  }
  final parsedDate = DateTime.tryParse(value);
  if (parsedDate != null) return formatChatTime(parsedDate);

  final match = RegExp(
    r'^(Today|Yesterday)\s+(\d{1,2}):(\d{2})\s*([AaPp][Mm])?$',
  ).firstMatch(value.trim());
  if (match == null) return value;

  final hour = int.parse(match.group(2)!);
  final minute = int.parse(match.group(3)!);
  final period = match.group(4)?.toUpperCase();
  final parsedTime = DateTime(2000, 1, 1, hour, minute);
  if (period == null) return formatChatTime(parsedTime);
  final normalizedHour = hour % 12 + (period == 'PM' ? 12 : 0);
  return formatChatTime(DateTime(2000, 1, 1, normalizedHour, minute));
}
