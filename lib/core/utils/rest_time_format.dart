/// Formats rest seconds as `90s` / `1:30` (DOC_6 §1.5); null → "—".
String formatRestTime(int? seconds) {
  if (seconds == null) return '—';
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
