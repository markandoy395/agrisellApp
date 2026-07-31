import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/responsive.dart';

class BuyerResponsiveText extends StatelessWidget {
  const BuyerResponsiveText({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final widthProgress = ((mediaQuery.size.width - 320) / 110)
        .clamp(0.0, 1.0)
        .toDouble();
    final fontRangeScale = lerpDouble(0.65, 1, widthProgress);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: _BuyerTextScaler(
          base: mediaQuery.textScaler,
          fontRangeScale: fontRangeScale,
        ),
      ),
      child: child,
    );
  }
}

final class _BuyerTextScaler extends TextScaler {
  const _BuyerTextScaler({required this.base, required this.fontRangeScale});

  final TextScaler base;
  final double fontRangeScale;

  @override
  double scale(double fontSize) {
    final responsiveSize = fontSize <= 12
        ? fontSize
        : 12 + ((fontSize - 12) * fontRangeScale);
    return base.scale(responsiveSize);
  }

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) {
    return other is _BuyerTextScaler &&
        other.base == base &&
        other.fontRangeScale == fontRangeScale;
  }

  @override
  int get hashCode => Object.hash(base, fontRangeScale);
}
