/// Normalizes incoming backend `goal` values for display/comparison.
///
/// DOC_7: every `goal` in responses now uses spaces instead of underscores
/// (`muscle_building` → `muscle building`). Stored values are unchanged —
/// only the response is formatted, so legacy underscore strings are handled
/// defensively here at the parsing boundary.
///
/// Outgoing request mappings (space → underscore) are intentionally untouched.
String? normalizeGoal(String? raw) {
  if (raw == null) return null;
  return raw.replaceAll('_', ' ');
}

/// Non-nullable variant of [normalizeGoal] for required goal fields.
String normalizeGoalValue(String raw) => raw.replaceAll('_', ' ');
