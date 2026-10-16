import 'package:agresell_app/core/services/agrisell_supabase.dart';

/// Resolve upload object keys without making private evidence public or signed.
String? riderProofImageUrl(String reference) {
  final uri = Uri.tryParse(reference);
  if (uri == null) return null;
  if (uri.scheme == 'https' || uri.scheme == 'http') return reference;
  if (uri.hasScheme || uri.hasQuery || uri.hasFragment) return null;
  final parts = uri.pathSegments;
  if (parts.length != 4 ||
      !RegExp(r'^[a-fA-F0-9-]{36}$').hasMatch(parts[0]) ||
      !RegExp(r'^[A-Za-z0-9-]+$').hasMatch(parts[1]) ||
      !{'pickup', 'delivery'}.contains(parts[2]) ||
      !RegExp(
        r'^[A-Za-z0-9_-]+\.(jpg|jpeg|png|webp|heic)$',
        caseSensitive: false,
      ).hasMatch(parts[3])) {
    return null;
  }
  final project = Uri.parse(AgrisellSupabase.projectUrl);
  return Uri(
    scheme: project.scheme,
    host: project.host,
    port: project.hasPort ? project.port : null,
    pathSegments: [
      'storage',
      'v1',
      'object',
      'authenticated',
      'delivery-proofs',
      ...parts,
    ],
  ).toString();
}
