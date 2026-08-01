import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';

class HomeAssetIcon extends StatelessWidget {
  const HomeAssetIcon({
    required this.asset,
    required this.size,
    this.color = AgrisellColors.brandBlack,
    super.key,
  });

  final String asset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ResponsiveAssetImage(
      asset: asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
