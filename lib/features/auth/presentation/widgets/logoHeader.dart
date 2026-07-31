import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';

enum LogoHeaderStyle { horizontal, stacked, mark }

class LogoHeader extends StatelessWidget {
  const LogoHeader({
    this.style = LogoHeaderStyle.horizontal,
    this.widthMin = 96,
    this.widthMax = 132,
    super.key,
  });

  final LogoHeaderStyle style;
  final double widthMin;
  final double widthMax;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    final logoWidth = lerpDouble(widthMin, widthMax, scale);

    return ResponsiveAssetImage(
      asset: _asset,
      width: logoWidth,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      semanticLabel: 'Agrisell logo',
    );
  }

  String get _asset {
    return switch (style) {
      LogoHeaderStyle.horizontal => AgrisellAssets.logoLandscape,
      LogoHeaderStyle.stacked => AgrisellAssets.logoPrimary,
      LogoHeaderStyle.mark => AgrisellAssets.logoMark,
    };
  }
}
