import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/responsive_asset_image.dart';

class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.semanticLabel,
    this.asset,
    this.imageBytes,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = false,
    super.key,
  }) : assert(asset != null || imageBytes != null || imageUrl != null);

  const ProductThumbnail.square({
    required double size,
    required this.borderRadius,
    required this.semanticLabel,
    this.asset,
    this.imageBytes,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = false,
    super.key,
  }) : width = size,
       height = size,
       assert(asset != null || imageBytes != null || imageUrl != null);

  final String? asset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final String semanticLabel;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: ResponsiveAssetImage(
      asset: asset,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
    ),
  );
}
