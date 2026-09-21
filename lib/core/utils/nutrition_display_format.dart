import 'package:intl/intl.dart';

String formatNutrition(num value) =>
    NumberFormat('#,##0.#', 'en').format(value);
