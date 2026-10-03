import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/image_loading_skeleton.dart';

class ResponsiveAssetImage extends StatelessWidget {
  const ResponsiveAssetImage({
    this.asset,
    this.imageBytes,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.low,
    this.color,
    this.colorBlendMode,
    this.gaplessPlayback = false,
    this.decodeWidth,
    this.decodeHeight,
    this.maxDecodedWidth = 2048,
    this.maxDecodedHeight = 2048,
    super.key,
  }) : assert(asset != null || imageBytes != null || imageUrl != null),
       assert(decodeWidth == null || decodeWidth > 0),
       assert(decodeHeight == null || decodeHeight > 0);

  final String? asset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final FilterQuality filterQuality;
  final Color? color;
  final BlendMode? colorBlendMode;
  final bool gaplessPlayback;
  final int? decodeWidth;
  final int? decodeHeight;
  final int maxDecodedWidth;
  final int maxDecodedHeight;

  @override
  Widget build(BuildContext context) {
    final explicitWidth = _validExtent(width);
    final explicitHeight = _validExtent(height);
    if (explicitWidth != null || explicitHeight != null) {
      return _buildImage(context, explicitWidth, explicitHeight);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final logicalWidth = _resolveLogicalExtent(width, constraints.maxWidth);
        final logicalHeight = _resolveLogicalExtent(
          height,
          constraints.maxHeight,
        );
        return _buildImage(context, logicalWidth, logicalHeight);
      },
    );
  }

  Widget _buildImage(
    BuildContext context,
    double? logicalWidth,
    double? logicalHeight,
  ) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        decodeWidth ?? _cacheExtent(logicalWidth, pixelRatio, maxDecodedWidth);
    final cacheHeight =
        decodeHeight ??
        _cacheExtent(logicalHeight, pixelRatio, maxDecodedHeight);
    final imageBytes = this.imageBytes;

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
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
      );
    }

    final imageUrl = this.imageUrl;
    if (imageUrl != null) {
      return authenticatedNetworkImage(
        imageUrl,
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const ImageLoadingSkeleton();
        },
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      );
    }

    return Image.asset(
      asset!,
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
    );
  }

  double? _validExtent(double? extent) {
    return extent != null && extent.isFinite && extent > 0 ? extent : null;
  }

  double? _resolveLogicalExtent(double? explicit, double constrained) {
    if (explicit != null && explicit.isFinite && explicit > 0) {
      return explicit;
    }

    if (constrained.isFinite && constrained > 0) {
      return constrained;
    }

    return null;
  }

  int? _cacheExtent(double? logicalExtent, double pixelRatio, int maxExtent) {
    if (logicalExtent == null || maxExtent <= 0) {
      return null;
    }

    return (logicalExtent * pixelRatio).ceil().clamp(1, maxExtent).toInt();
  }
}
