import 'package:flutter/material.dart';
import 'agrisell_supabase.dart';

/// Never send a user's bearer token to an external image host.
bool _isProjectStorage(Uri? uri) {
  final project = Uri.parse(AgrisellSupabase.projectUrl);
  return uri != null &&
      uri.scheme == project.scheme &&
      uri.host == project.host &&
      uri.port == project.port &&
      uri.path.startsWith('/storage/v1/object/');
}

String authenticatedStorageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (!_isProjectStorage(uri)) return url;
  final path = uri!.path.replaceFirst(
    RegExp(r'^/storage/v1/object/(public|sign)/'),
    '/storage/v1/object/authenticated/',
  );
  return uri
      .replace(path: path, query: '')
      .removeFragment()
      .toString()
      .split('?')
      .first;
}

Map<String, String>? storageImageHeaders(String url) {
  if (!_isProjectStorage(Uri.tryParse(url)) ||
      !AgrisellSupabase.isInitialized) {
    return null;
  }
  final session = AgrisellSupabase.client.auth.currentSession;
  if (session == null || session.isExpired || session.user.isAnonymous) {
    return null;
  }
  return {'Authorization': 'Bearer ${session.accessToken}'};
}

/// The URL remains stable; credentials are supplied only at render time.
Image authenticatedNetworkImage(
  String url, {
  double? width,
  double? height,
  BoxFit? fit,
  AlignmentGeometry alignment = Alignment.center,
  String? semanticLabel,
  bool excludeFromSemantics = false,
  FilterQuality filterQuality = FilterQuality.medium,
  Color? color,
  BlendMode? colorBlendMode,
  bool gaplessPlayback = false,
  int? cacheWidth,
  int? cacheHeight,
  ImageLoadingBuilder? loadingBuilder,
  ImageErrorWidgetBuilder? errorBuilder,
}) => Image.network(
  authenticatedStorageUrl(url),
  headers: storageImageHeaders(url),
  width: width,
  height: height,
  fit: fit,
  alignment: alignment,
  semanticLabel: semanticLabel,
  excludeFromSemantics: excludeFromSemantics,
  filterQuality: filterQuality,
  color: color,
  colorBlendMode: colorBlendMode,
  gaplessPlayback: gaplessPlayback,
  cacheWidth: cacheWidth,
  cacheHeight: cacheHeight,
  loadingBuilder: loadingBuilder,
  errorBuilder: errorBuilder,
);
