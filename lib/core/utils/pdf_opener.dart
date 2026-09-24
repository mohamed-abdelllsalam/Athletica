import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/widgets/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resolves a raw PDF URL string to an absolute http/https URL.
/// Returns null if the value cannot be resolved to a valid PDF URL.
/// Shared by [openPdfUrl] and [PdfViewerScreen] to keep validation consistent.
String? resolvePdfUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  Uri? uri = Uri.tryParse(trimmed);
  uri ??= Uri.tryParse(Uri.encodeFull(trimmed));
  if (uri == null) return null;

  // Resolve relative URLs (e.g. "/storage/file.pdf") against the API base
  // URL. Backend may return absolute or relative paths. Bare filenames like
  // "certificate.pdf" are NOT treated as relative (test expects false) — only
  // values containing a '/' are resolved.
  if (!uri.hasScheme) {
    if (!trimmed.contains('/')) return null;
    try {
      final base = Uri.tryParse(ApiEndpoints.baseUrl);
      if (base != null) {
        uri = base.resolveUri(uri);
      }
    } catch (_) {
      // AppConfig not initialized in tests — keep as relative and fail closed.
      return null;
    }
  }

  if (!uri.hasScheme ||
      !uri.hasAuthority ||
      !{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
    return null;
  }

  // Validate that we have a non-empty host.
  if (uri.host.isEmpty) return null;

  return uri.toString();
}

Future<bool> openPdfUrl(String value) async {
  final resolved = resolvePdfUrl(value);
  if (resolved == null) return false;
  final uri = Uri.parse(resolved);
  try {
    // Prefer externalApplication (browser/PDF viewer) but fall back to
    // platformDefault for desktop where externalApplication may be unsupported.
    if (await canLaunchUrl(uri)) {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
    return false;
  } catch (_) {
    try {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }
}

Future<void> openPdfFromContext(
  BuildContext context,
  String value, {
  String? title,
}) async {
  final resolved = resolvePdfUrl(value);
  if (resolved == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The PDF could not be opened. Please try again.'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PdfViewerScreen(url: resolved, title: title),
    ),
  );
}
