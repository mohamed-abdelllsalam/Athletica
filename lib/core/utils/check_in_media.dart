import 'package:dio/dio.dart';

/// Backend upload limits (CHECK_IN.md §6): jpeg/png/webp, 5 MB per file,
/// max 10 files per submission.
const int kCheckInMaxImageBytes = 5 * 1024 * 1024;
const int kCheckInMaxImageCount = 10;

/// Actual MIME type for a check-in image file, derived from its extension.
/// Returns null for unsupported types (backend allows jpeg/png/webp only).
DioMediaType? checkInMimeForPath(String path) {
  final ext = path.split('.').last.toLowerCase();
  return switch (ext) {
    'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
    'png' => DioMediaType('image', 'png'),
    'webp' => DioMediaType('image', 'webp'),
    _ => null,
  };
}

/// True when [path] has a backend-supported image extension.
bool isSupportedCheckInImagePath(String path) =>
    checkInMimeForPath(path) != null;
