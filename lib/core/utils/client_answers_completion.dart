/// Backend-totals completion rule for client questionnaire answers (DOC_7).
///
/// `total` = distinct question groups answered, `total_questions` = per
/// language total. Array length must never decide completion: bilingual
/// en+ar double answers can make `answers.length` exceed the distinct total.
int? parseCompletionCount(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}

/// Returns true only when `total >= total_questions` with a positive total.
/// Non-map payloads and missing totals (without a usable fallback) are
/// incomplete. Callers needing throw-vs-false semantics handle errors
/// themselves; this function is pure.
bool isClientAnswersComplete(Object? data) {
  if (data is! Map<String, dynamic>) return false;
  final answers = data['answers'] as List<dynamic>? ?? const [];
  final total = parseCompletionCount(data['total']) ?? answers.length;
  final totalQuestions = parseCompletionCount(data['total_questions']) ?? 0;
  return totalQuestions > 0 && total >= totalQuestions;
}
