import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/app_font_size_controller.dart';

/// Applies the saved in-app size preference while retaining device text scaling.
class AppFontSizeScope extends StatelessWidget {
  const AppFontSizeScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppFontSizeController.instance,
      child: child,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _AppTextScaler(
              base: mediaQuery.textScaler,
              additionalScale: AppFontSizeController.instance.textScale,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class _AppTextScaler extends TextScaler {
  const _AppTextScaler({required this.base, required this.additionalScale});

  final TextScaler base;
  final double additionalScale;

  @override
  double scale(double fontSize) => base.scale(fontSize) * additionalScale;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _AppTextScaler &&
      other.base == base &&
      other.additionalScale == additionalScale;

  @override
  int get hashCode => Object.hash(base, additionalScale);
}
