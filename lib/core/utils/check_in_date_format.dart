import 'package:intl/intl.dart';

String formatCheckInDate(DateTime? date) => date == null
    ? 'Time unavailable'
    : DateFormat('d MMM yyyy, h:mm a', 'en_US').format(date.toLocal());
