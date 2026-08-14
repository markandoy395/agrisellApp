import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({this.onLoaded, super.key});

  static const _maxDecodedHeight = 1989;

  final VoidCallback? onLoaded;

  static Future<void> precache(BuildContext context) {
    return precacheImage(providerFor(context), context);
  }

  static ImageProvider providerFor(BuildContext context) {
    return providerForSize(
      MediaQuery.sizeOf(context),
      MediaQuery.devicePixelRatioOf(context),
    );
  }

  static ImageProvider providerForSize(Size size, double devicePixelRatio) {
    final rawHeight = math.max(1, (size.height * devicePixelRatio).round());
    return ResizeImage(
      const AssetImage(AgrisellAssets.authBackground),
      // A height-only decode preserves the source aspect ratio before
      // BoxFit.cover crops it to the portrait viewport.
      height: math.min(rawHeight, _maxDecodedHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AgrisellColors.forestSoft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fallbackSize = MediaQuery.sizeOf(context);
          final size = constraints.biggest.isFinite
              ? constraints.biggest
              : fallbackSize;

          return Image(
            image: providerForSize(
              size,
              MediaQuery.devicePixelRatioOf(context),
            ),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                _notifyLoaded();
                return child;
              }

              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, _, _) {
              _notifyLoaded();
              return const SizedBox.expand();
            },
          );
        },
      ),
    );
  }

  void _notifyLoaded() {
    final callback = onLoaded;

    if (callback == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }
}
