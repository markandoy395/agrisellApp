import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';

/// Local exports from the supplied Figma frames; preserve their aspect ratios.
class BuyerCatalogIcon extends StatelessWidget {
  const BuyerCatalogIcon(this.name, {this.size = 18, super.key});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => ResponsiveAssetImage(
    asset: 'assets/icons/buyer_catalog_$name.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
