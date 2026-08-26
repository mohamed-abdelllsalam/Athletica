/// Builds a single display label from API-provided translations.
///
/// The backend food catalog supplies `name` (default), plus optional
/// `name_ar` and `name_en` fields; this joins both languages so neither
/// is hardcoded on the client.
///
/// Order follows the product's ar/en convention: Arabic first.
String buildBilingualLabel({
  required String primary,
  String? arabic,
  String? english,
}) {
  final parts = <String>[];

  var ar = arabic?.trim() ?? '';
  if (ar.isEmpty) ar = primary.trim();
  if (ar.isNotEmpty) parts.add(ar);

  var en = english?.trim() ?? '';
  if (en.isNotEmpty && !parts.contains(en)) parts.add(en);

  return parts.join(' / ');
}
