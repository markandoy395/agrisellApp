import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'dart:io';

import 'package:flutter/material.dart';

class SafeCircleAvatar extends StatelessWidget {
  const SafeCircleAvatar({
    required this.radius,
    required this.fallback,
    this.imageUrl,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final double radius;
  final String? imageUrl;
  final Widget fallback;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim();
    final image = source == null || source.isEmpty
        ? null
        : _AvatarImage(source: source, radius: radius);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radius * 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: fallback),
              if (image != null) image,
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.source, required this.radius});

  final String source;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final cacheExtent = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    final uri = Uri.tryParse(source);
    if (uri?.hasScheme ?? false) {
      final sanitized = source.replaceAll(RegExp(r'\s+'), '');
      return authenticatedNetworkImage(
        sanitized,
        width: size,
        height: size,
        cacheWidth: cacheExtent,
        cacheHeight: cacheExtent,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }
    return Image.file(
      File(source),
      width: size,
      height: size,
      cacheWidth: cacheExtent,
      cacheHeight: cacheExtent,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
